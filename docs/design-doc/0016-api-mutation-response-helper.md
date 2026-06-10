# 0016 API CRUD ボイラープレート（mutation response）の共通化

> **scope**: api | **date**: 2026-05-09 | **issue**: #45

## 概要

API 層の create / update / delete レスポンスで重複している
「結果に応じて status 文字列と HTTP ステータスを設定し `Common::Response` で present する」
ボイラープレートを、Grape の helper メソッドに切り出して共通化する。
あわせて、`if result` / `if result.present?` の判定式の揺れと、`records.rb` の代入順序の不統一を解消する。

## 背景

issue #45 で観察された通り、4 つの API ファイル（categories / records / payment_methods / invoice_records）に
合計 8 箇所の create/update が同型のコードを複製しており、以下の揺れがある。

- `if result` 版（4 箇所）と `if result.present?` 版（4 箇所）が混在
- `records.rb:64-69`（create）だけ `status = "success"` と `status 422`/`status = "failed"` の代入順序が他と逆
- 認可チェックや監査ログの追加が必要になった場合、全エンドポイントを横断的に修正することになる

Service 層は既に「成功時は ActiveRecord オブジェクト、失敗時は nil/false」を返す形でほぼ統一されている
（`api/db/repositories.rb` の `return record if record.update(...)` パターン）。
本リファクタはこの暗黙の契約を Design Doc 上で明文化し、API 層からその契約に依存して共通化する。

## 目標

- API 層の create / update / delete における status 設定と present 処理を共通 helper に集約する
- 判定式を `if result`（nil/false 判定）に統一する
- Service 層の create / update の戻り値契約を Design Doc 上で明文化する
  - 成功時: 永続化されたモデルオブジェクト（ActiveRecord）
  - 失敗時: nil / false
- 既存 spec がグリーンのまま通ることを保証する

## 非目標

- Service 層の戻り値の構造変更（`{ status:, id: }` を Service 側で返すような変更はしない）
- エラーハンドリングの方針変更（例外を rescue するかどうかなど）
- Service 層のメソッドシグネチャ変更
- 認可チェック・監査ログの実装（共通化後の差し込みポイントは確保するが、本 PR では機能追加しない）
- view 系（GET 系）の共通化（present の root や entity が個別なため対象外）

## 設計

### helper メソッドの追加

`api/app/api/root.rb` の `helpers` ブロックに `present_mutation_response` を追加する。

```ruby
# api/app/api/root.rb
helpers do
  # 既存の authorization_header / request_bearer / request_userdata はそのまま

  # create / update 用: result が truthy なら success、falsy なら 422 で failed
  # @param result [ActiveRecord::Base, nil, false] Service の戻り値
  def present_mutation_response(result)
    if result
      response_status = "success"
    else
      status 422
      response_status = "failed"
    end
    resp = { status: response_status, id: result&.id }
    present resp, with: API::Entities::Common::Response
  end

  # delete 用: 成功時は status="success" と id を返すだけ（失敗は Service から例外）
  # @param id [String] 削除対象 ID
  def present_delete_response(id)
    resp = { status: "success", id: }
    present resp, with: API::Entities::Common::Response
  end
end
```

### 呼び出し側のリファクタ例

**Before** (`api/app/api/v1/categories.rb:29-42`):

```ruby
post do
  uid = request_userdata[:uid]
  categories_service = Service::Categories.new(uid:)
  category = categories_service.create(label: params[:label])

  if category
    status = "success"
  else
    status = "failed"
    status 422
  end
  resp = { status:, id: category&.id }
  present resp, with: API::Entities::Common::Response
end
```

**After**:

```ruby
post do
  uid = request_userdata[:uid]
  category = Service::Categories.new(uid:).create(label: params[:label])
  present_mutation_response(category)
end
```

### Service 層の戻り値契約（明文化）

本 PR では Service 層のコードは変更しない。
ただし以降のメンテナンスのため、戻り値契約を以下のように明文化する。

| メソッド | 成功時 | 失敗時 |
|---------|-------|-------|
| `Service::*.create` | 永続化済みの ActiveRecord オブジェクト | `nil` または `false` |
| `Service::*.update` | 更新済みの ActiveRecord オブジェクト | `nil` または `false` |
| `Service::*.delete` | 戻り値は使わない（失敗時は例外で表現） | `Exceptions::*` を raise |

この契約は `api/db/repositories.rb` の `return record if record.update(...)` パターンによって
既に実態としては成立している。本 Design Doc に記載することで暗黙の合意を明示化する。

### `records.rb` create の代入順序統一

`records.rb:64-69` の以下の崩れた順序を、helper 化に伴い自然に解消する。

```ruby
# Before（status 422 と status = "failed" の順序が他と逆）
if record
  status = "success"
else
  status 422
  status = "failed"
end
```

helper 化後は `present_mutation_response(record)` 一行になるため、揺れは消える。

## 変更ファイル一覧

- `api/app/api/root.rb` — `helpers` ブロックに `present_mutation_response` と `present_delete_response` を追加
- `api/app/api/v1/categories.rb` — post / put :id を helper 呼び出しに置き換え（2 箇所）
- `api/app/api/v1/records.rb` — post / put :id を `present_mutation_response` に、delete :id を `present_delete_response` に置き換え（3 箇所）
- `api/app/api/v1/payment_methods.rb` — post / put :id を helper 呼び出しに置き換え（2 箇所）
- `api/app/api/v1/invoice_records.rb` — post / put :id を `present_mutation_response` に、delete :id を `present_delete_response` に置き換え（3 箇所）

合計: helper 追加 1 ファイル + リファクタ 4 ファイル、置き換え箇所 10 箇所。

## 実装ステップ

各ステップは独立したコミット単位を想定。

1. **helper 追加**: `api/app/api/root.rb` に `present_mutation_response` と `present_delete_response` を追加する。この時点では呼び出し側は変更しない。テスト実行して既存挙動に影響がないことを確認する。
2. **categories.rb リファクタ**: post / put :id を helper 呼び出しに置き換え。`./scripts/test/api-test.sh` で当該リソースの spec が通ることを確認。
3. **payment_methods.rb リファクタ**: post / put :id を helper 呼び出しに置き換え。spec 確認。
4. **records.rb リファクタ**: post / put :id / delete :id を helper 呼び出しに置き換え。`records.rb:64-69` の代入順序の揺れもこのコミットで解消される。spec 確認。
5. **invoice_records.rb リファクタ**: post / put :id / delete :id を helper 呼び出しに置き換え。spec 確認。
6. **全体テスト & PR 作成**: `./scripts/test/api-test.sh` を全リソース対象で実行してグリーンを確認。`Closes: #45` を含む PR を作成。

## テスト方針

- 既存 API spec のグリーン維持で十分（helper のロジックは既存コードと等価な置き換えのため）
- `api/spec/api/v1/` 配下の create / update / delete に関する spec を実行し、success / failure（422）両ケースが既にカバーされていることを確認する
- カバレッジが薄ければ最小限の spec を追加する判断は実装ステップ内で行う

## 代替案

### 採用しなかった: Concern モジュール化

`API::V1::Concerns::MutationResponse` モジュールを作って各 Grape::API クラスに `helpers` 経由で include する案。
helper が 2 つ程度の現状では、独立モジュール化のオーバーヘッドが利益を上回るため不採用。
将来 helper が増えた段階で `api/app/api/root.rb` から切り出せばよい。

### 採用しなかった: Service 層に status 構造を返させる

`Service::*.create` が `{ status:, id:, http_status: }` のようなハッシュを返し、API 層は present するだけにする案。
- Service 層の責務が「ビジネスロジック」から「HTTP レスポンス整形」にまで広がってしまう
- 直近で完了した issue #50 / #51（Service-Repository 責務整理 / Entity 表示整形 Formatter 化）の方向と逆行する
- 現状の戻り値契約（成功: object / 失敗: nil）が既にシンプルかつ十分であるため不採用

### 採用しなかった: delete を共通化対象外にする

delete は失敗時に例外を投げる設計で create / update とフロー自体は異なるが、
「成功時に `{ status: 'success', id: }` を `Common::Response` で present する」という最後の整形パターンは同型のため、
小さな helper（`present_delete_response`）として揃えることで揺れの再発を防ぐ。

## 未解決事項

- 特になし。Service 層の戻り値契約は既存実装と整合しているため、API 層のリファクタのみで完結する。

---

## 実装サマリー

> **実装日**: 2026-06-09

### 変更ファイル

- `api/app/api/root.rb` — `helpers` ブロックに `present_mutation_response` / `present_delete_response` を追加
- `api/app/api/v1/categories.rb` — post / put を `present_mutation_response` に置き換え（2 箇所）
- `api/app/api/v1/payment_methods.rb` — post / put を `present_mutation_response` に置き換え（2 箇所）
- `api/app/api/v1/records.rb` — post / put を `present_mutation_response`、delete を `present_delete_response` に置き換え（3 箇所）。create の代入順序の崩れも解消
- `api/app/api/v1/invoice_records.rb` — post / put を `present_mutation_response`、delete を `present_delete_response` に置き換え（3 箇所）。あわせて PUT params の `:id` 型不整合を修正（後述）
- `api/spec/api/v1/payment_methods_spec.rb` — 新規。GET / POST / PUT の正常系（3 ケース）
- `api/spec/api/v1/invoice_records_spec.rb` — 新規。POST / PUT の正常系（2 ケース）

コミットは 2 つに分割した。

- `fix(api): correct invoice_records update :id param type to String`
- `refactor(api): consolidate mutation response boilerplate into helpers`

### 実装内容

ddoc の設計どおり、helper 2 つを `root.rb` に追加し、4 リソース計 10 箇所の create / update / delete を helper 呼び出しに置き換えた。設計との差分は以下。

- helper の実装は ddoc の擬似コードのとおり、`status`（Grape のレスポンスステータス設定メソッド）とローカル変数の衝突を避けるため `response_status` を使用した。
- ddoc の After 例では呼び出し側で `Service::Categories.new(uid:).create(...)` とメソッドチェーンしていたが、差分最小化と既存の `*_service` 変数命名スタイル維持のため、status 設定 + present の箇所のみを helper 呼び出しに置き換えた（Service の生成・呼び出し部分は既存のまま）。
- ddoc のテスト方針「カバレッジが薄ければ最小限の spec を追加」に従い、spec が未整備だった payment_methods / invoice_records に正常系 spec を新規追加した（categories / records には既存 spec あり）。

### 確認・検証

- `./scripts/test/api-test.sh` で全体実行。**37 examples, 1 failure**。
- 追加した payment_methods 3 ケース・invoice_records 2 ケースを含め、失敗 1 件を除く全ケースがグリーン。
- 唯一の失敗 `records_spec.rb:29`（GET で作成レコードが一覧に出ない）は、`git stash` で本変更を退避した HEAD 状態でも同一理由で失敗することを確認済み。**本リファクタとは無関係の既存問題**であり、本 PR のスコープ外。

### 気づき・備考

- **invoice_records の `:id` 型不整合（ddoc 外で発見・修正）**: PUT の params が `requires :id, type: Integer` だったが、ID は全リソース共通で `ID.generate`（nanoid の 12 文字英数字文字列）であり、DB スキーマ（`db/models.rb` の `InvoiceRecord`）も `id` を `string` primary_key として定義している。他の全エンドポイント（および invoice_records 自身の delete）は `type: String`。Integer 型強制のため、英字を含む nanoid を載せた PUT は 400 で弾かれ、数字のみの id が偶然来たときしか更新できなかった。invoice 実装初期に Integer 連番 PK を想定していた名残が nanoid String PK 統一時に PUT だけ直し漏れたものと推測。`type: String` に修正し、修正により書けるようになった PUT 正常系 spec も追加した。
- **フロントへの影響なし**: `front/src/lib/api/v1/types.d.ts` の `UpdateInvoiceRecordRequest.id` は既に `string`、PUT 呼び出しも URL テンプレートへの文字列埋め込み（`v1/invoice_records/${req.id}`）。今回の API 修正はフロントの実態に API を一致させる方向であり、フロント側の変更は不要。むしろ従来フロントが nanoid で PUT すると更新失敗していた不具合が解消される。
- **未着手の関連事項**: `records_spec.rb:29` の GET 一覧不一致（既存の問題）と、`invoice_records.rb` の post 先頭に残る `puts params.inspect`（デバッグ出力、本 PR スコープ外のため未削除）は別途対応の余地がある。
