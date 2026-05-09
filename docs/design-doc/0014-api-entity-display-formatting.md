# 0014 Service 層の表示用整形責務を明確化し Entity を純粋な Presenter にする

> **scope**: api | **date**: 2026-05-09

## 概要

issue #51 が指摘する「Entity が受け取る入力形式がリソースごとに揺れている」「API 層に平坦化ロジックがある」という問題を、**Service 側に表示用整形の責務を寄せて規約を固定する** ことで解消する。

具体的には以下の方針を採る:

- **Service** がリソースごとに「API レスポンスの形に整った平坦ハッシュ」を返す責務を負う
- **Service ごとに専用の Formatter クラス** を用意し、整形ロジックを集約する
- **カラム単位の変換ヘルパー**（暗号化ラベル復号 + TODO フォールバック等）は共通モジュール `FieldFormatter` に集約し、各 Formatter から呼び出す。スキーマ変更時の重複を避ける
- **UserHash（復号鍵）は Service 内に閉じる**。Entity は UserHash を一切知らない
- **Entity は presenter に徹し**、フォーマット変換（ISO8601 等）以外のロジックを持たない
- **API 層の平坦化ロジック**（`api/app/api/v1/invoice_records.rb:33-45`）は Service へ移す

関連 issue: [#51](https://github.com/ToshihitoKon/finascope/issues/51)

## 背景

issue #51 が問題視しているのは以下の 3 点:

1. Entity が受け取る入力形式がリソースごとに揺れている（categories はそのまま present、invoice_records は API 層で再構築）
2. API 層に平坦化ロジックがある（`record.dig(:invoice, :id)` 等）
3. Entity と Service・API 層の責務境界が曖昧で、新規追加時の判断材料がない

issue 本文には「Entity 層に整形・復号を寄せる」という選択肢もあるが、Grape Entity の一般的な使い方は presenter（受け取った値オブジェクトを JSON 形に射影する層）であり、復号や ID→ラベル変換は Service の責務と捉えるほうが自然。今回は **Service に責務を集約し、Entity は presenter に徹する** 方向で規約を固定する。

`Service ↔ Repository の責務再整理`（issue #50）では `RecordFormatter` が抽出され、records / view / invoice_records の整形に使われている。今回はその方針を categories / payment_methods / invoice_records（invoice 自体）へも展開する。

## 目標

- Service が「API レスポンスに整った平坦ハッシュ」を返す規約を確立する
- リソースごとに専用 Formatter クラスを置き、整形ロジックを集約する
- API 層から平坦化ロジックを排除する（`invoice_records.rb:33-45`）
- Entity を「expose のみ + フォーマット変換のみ」の純粋な presenter にする
- Service 間の直接結合（`Service::FinanceRecords.new` の埋め込み呼び出し等）が完全に解消されていることを再検証し、残っていれば今回スコープで仕上げる
- リファクタリング前後で API レスポンスの内容が変わらないこと（既存 spec が通ること）

## 非目標

- Entity 層への整形・復号ロジックの移譲（issue #51 の文面とは異なる方針を採るため明示）
- Service の戻り値の型導入（Struct/Data クラス化）
- フロントエンドに公開している API レスポンスの形の変更（互換性維持）
- Repository 層の戻り値の構造変更

## 設計

### Entity の責務（規約）

Entity は **presenter に徹する**。具体的には:

- `expose :field` で Service が返したハッシュのフィールドをそのまま JSON に射影する
- `format_with: :iso_timestamp` 等の **フォーマット変換のみ許容** する
- ブロック expose（`expose :x do |obj, opts| ... end`）は使わない
- options（`present(records, with: ..., uhash: ...)` の追加引数）は使わない
- UserHash や Constants を Entity から参照しない

### Service の責務（規約）

Service は **API レスポンスに揃った平坦ハッシュを返す** 責務を負う。具体的には:

- 暗号化フィールドの復号は Service（実体は Formatter）で行い、Entity に渡すハッシュには `encrypted_*` を含めない
- ID → ラベル変換（`Constants.record_state(state_id)[:label]` 等）も Service で行う
- ネスト構造を平坦化して返す（API 層で `record.dig(...)` するような構造にしない）

### カラム単位の共通ヘルパー: `FieldFormatter`

スキーマ変更や、同じカラム形式（`encrypted_label` を持つラベル類）を複数リソースで扱うときの重複を避けるため、**カラム単位の整形** を共通モジュールに集約する。

`api/lib/field_formatter.rb`:

```ruby
module FieldFormatter
  module_function

  # 暗号化されたラベル系カラム（encrypted_label / encrypted_category 等）を平文へ。
  # encrypted が nil の場合は TODO_LABEL を返す（既存の挙動踏襲）。
  TODO_LABEL = "TODO"

  def label(encrypted, uhash)
    return TODO_LABEL if encrypted.nil?

    uhash.decrypt(encrypted)
  end

  # 任意フィールド（encrypted_title / encrypted_description 等）の復号。
  # nil なら nil を返す（既存挙動: 値がなければ空文字相当の扱い）。
  def text(encrypted, uhash)
    return nil if encrypted.nil?

    uhash.decrypt(encrypted)
  end

  # Constants 経由のラベル参照（id → label）。
  def constant_label(constants_lookup_result)
    constants_lookup_result&.dig(:label)
  end
end
```

各 Formatter はこのヘルパーを呼ぶだけにする。スキーマで新たな `encrypted_*` カラムが増えたときも、ラベル系なら `FieldFormatter.label` を呼ぶだけで済み、TODO フォールバック・nil 処理の方針変更も 1 箇所で完結する。

### Formatter クラス

リソースごとに専用 Formatter クラスを `api/lib/` 配下に置く。

- `api/lib/category_formatter.rb` — `Service::Categories` 用
- `api/lib/payment_method_formatter.rb` — `Service::PaymentMethods` 用
- `api/lib/finance_record_formatter.rb` — `Service::FinanceRecords` / `Service::View` 用（既存の `record_formatter.rb` をリネーム）
- `api/lib/invoice_record_formatter.rb` — `Service::InvoiceRecords` 用

各 Formatter は `UserHash` をコンストラクタで受け取り、`format(raw_hash)` メソッドを提供する。整形ロジックは `FieldFormatter` を経由する。

```ruby
class CategoryFormatter
  def initialize(uhash:)
    @uhash = uhash
  end

  def format(record)
    {
      id: record[:id],
      label: FieldFormatter.label(record[:encrypted_label], @uhash)
    }
  end
end
```

`FinanceRecordFormatter` 例:

```ruby
class FinanceRecordFormatter
  def initialize(uhash:)
    @uhash = uhash
  end

  def format(record)
    {
      **record.except(:encrypted_title, :encrypted_description,
                      :encrypted_category, :encrypted_payment_method),
      title: FieldFormatter.text(record[:encrypted_title], @uhash) || "",
      description: FieldFormatter.text(record[:encrypted_description], @uhash) || "",
      record_type: FieldFormatter.constant_label(Constants.record_type(record[:record_type_id])),
      state: FieldFormatter.constant_label(Constants.record_state(record[:state_id])),
      category: FieldFormatter.label(record[:encrypted_category], @uhash),
      payment_method: FieldFormatter.label(record[:encrypted_payment_method], @uhash)
    }
  end
end
```

`InvoiceRecordFormatter` は `monthly_records` のネスト構造平坦化と `withdrawal_records_aggregation` の整形を担当する（後述）。

### 各 Service の戻り値（変更後）

| Service メソッド | 戻り値の形 |
|---|---|
| `Categories#all` | `[{ id:, label: }]` |
| `PaymentMethods#all` | `[{ id:, label:, withdrawal_day_of_month:, closing_day_of_month: }]` |
| `FinanceRecords#get_records` | 既存と同じ（`FinanceRecordFormatter#format` 適用後の平坦ハッシュ） |
| `InvoiceRecords#monthly_records` | API レスポンスに揃った平坦ハッシュ配列（後述） |
| `InvoiceRecords#withdrawal_records_aggregation` | 既存とほぼ同じ（`records` を formatter 適用後で返す） |
| `View#category_aggregation` | 既存と同じ（`records` を formatter 適用後で返す） |

### `InvoiceRecords#monthly_records` の戻り値（平坦化後）

現在 API 層 (`api/app/api/v1/invoice_records.rb:33-45`) が行っている平坦化を Service へ移す。

```ruby
# Service::InvoiceRecords#monthly_records が返すハッシュの例
{
  id: invoice_id_or_empty_string,
  amount: invoice_amount_or_zero,
  withdrawal_date: invoice_withdrawal_date_or_calced,
  state: state_label,             # Constants.invoice_record_state(state_id)[:label]
  state_id: state_id_or_zero,
  payment_method: payment_method_label,  # @uhash.decrypt(encrypted_label)
  payment_method_id: payment_method_id
}
```

これにより API 層は `present records, with: API::Entities::InvoiceRecords::InvoiceRecord, root: :records` を呼ぶだけになる。

### Service 間結合の再検証

#50 の作業で `Service::FinanceRecords.new` の Service 内埋め込み呼び出しは解消済み。今回も実装前に grep で再確認する:

```bash
grep -rn "Service::" api/services/
```

`api/services/` 配下に他の `Service::` 参照がないこと、`api/app/api/v1/` 配下の参照のみ（API 層からの呼び出しのみ）であることを確認する。漏れがあれば今回スコープで対応する。

### Entity の変更

各 Entity から `documentation:` 以外の不要な装飾を残しつつ、現状の `expose :field` 形式を維持する。`payment_methods.rb` / `categories.rb` は既に `label` を expose しているので変更なし。

`invoice_records.rb` の `WithdrawalRecordsAggregation` 内の `using: API::Entities::Records::Record` は維持（Service が返す `records` 配列も Formatter 適用後の平坦ハッシュなので互換）。

`view.rb` の `using: API::Entities::Records::Record` も同様。

## 変更ファイル一覧

### 新規

- `api/lib/field_formatter.rb` — カラム単位の共通変換ヘルパー（`label` / `text` / `constant_label`）
- `api/lib/category_formatter.rb` — `CategoryFormatter` クラス
- `api/lib/payment_method_formatter.rb` — `PaymentMethodFormatter` クラス
- `api/lib/invoice_record_formatter.rb` — `InvoiceRecordFormatter` クラス（`monthly_records` 平坦化と `withdrawal_records_aggregation` 整形）
- `api/spec/lib/field_formatter_spec.rb`
- `api/spec/lib/category_formatter_spec.rb`
- `api/spec/lib/payment_method_formatter_spec.rb`
- `api/spec/lib/invoice_record_formatter_spec.rb`

### リネーム

- `api/lib/record_formatter.rb` → `api/lib/finance_record_formatter.rb`（クラス名も `FinanceRecordFormatter` へ）
- `api/spec/lib/record_formatter_spec.rb` → `api/spec/lib/finance_record_formatter_spec.rb`

リネームは「records は finance records と invoice records の両方を含む」ため曖昧さを排除する目的。

### Service の変更

- `api/services/categories.rb` — `all` で `CategoryFormatter` を使うよう変更
- `api/services/payment_methods.rb` — `all` で `PaymentMethodFormatter` を使うよう変更
- `api/services/finance_records.rb` — `require` と クラス名を `FinanceRecordFormatter` に追従
- `api/services/invoice_records.rb` — `monthly_records` の平坦化を Formatter 経由で実施、`@formatter` も `FinanceRecordFormatter` に追従
- `api/services/view.rb` — `FinanceRecordFormatter` への追従

### API 層の変更

- `api/app/api/v1/invoice_records.rb` — 33-45 の平坦化ロジックを削除し、Service 戻り値を直接 `present`

### Spec の更新

- `api/spec/api/v1/records_spec.rb` — レスポンス内容に変更がないことを確認（既存パスで OK のはず）
- `api/spec/api/v1/categories_spec.rb` — 同上
- 必要に応じて `api/spec/api/v1/invoice_records_spec.rb` を新規追加（既存になし）

## 実装ステップ

1. **Service 間結合の再検証**
   - `grep -rn "Service::" api/services/` で残存結合がないことを確認
   - 残っていれば本ステップで解消（独立コミット）
2. **`FieldFormatter` を新設**
   - `api/lib/field_formatter.rb` を作成（`label` / `text` / `constant_label` の 3 メソッド）
   - `api/spec/lib/field_formatter_spec.rb` を作成
   - 既存 Formatter からはまだ使わない（独立コミット）
3. **`RecordFormatter` を `FinanceRecordFormatter` にリネーム + `FieldFormatter` 経由に置き換え**
   - ファイル・クラス名・require・spec をリネーム
   - 内部の復号・ラベル参照を `FieldFormatter` 経由に書き換え
   - `api/services/finance_records.rb` / `invoice_records.rb` / `view.rb` の参照も更新
   - テスト実行で全パス確認
4. **`CategoryFormatter` を新設**
   - `api/lib/category_formatter.rb` を作成
   - `api/spec/lib/category_formatter_spec.rb` を作成（mock UserHash 使用）
   - `Service::Categories#all` を Formatter 経由に変更
   - `api/spec/api/v1/categories_spec.rb` でレスポンス互換性を確認
5. **`PaymentMethodFormatter` を新設**
   - `api/lib/payment_method_formatter.rb` を作成
   - 対応 spec を作成
   - `Service::PaymentMethods#all` を Formatter 経由に変更
   - 既存の API spec で互換性確認（spec がなければ手動確認）
6. **`InvoiceRecordFormatter` を新設し、`monthly_records` 平坦化を Service へ移動**
   - `api/lib/invoice_record_formatter.rb` を作成
   - `monthly_records` の平坦化と `withdrawal_records_aggregation` の整形を担当
   - `api/spec/lib/invoice_record_formatter_spec.rb` を作成
   - `Service::InvoiceRecords#monthly_records` を新仕様（平坦ハッシュ返し）に変更
   - `api/app/api/v1/invoice_records.rb` の 33-45 を削除し、`present records, ...` だけにする
   - 必要なら `api/spec/api/v1/invoice_records_spec.rb` を新規追加
7. **テスト全体実行と PR 作成**
   - `./scripts/test/api-test.sh` でテスト全パス確認
   - PR description に `Closes: #51` を含める

## 代替案

### 代替案 1: Entity に options[:uhash] を渡して復号する（issue 本文の素直な解釈）

issue 本文が示唆していた、Entity の expose ブロック内で UserHash を呼び出す案。

- 短所:
  - Grape Entity の一般的な使い方（presenter）から外れる
  - Entity がビジネスロジック（ID→ラベル変換、復号）を持つことになり、責務境界が曖昧になる
  - すべての `present` 呼び出し箇所で `uhash:` を渡す必要があり、漏らすとバグる
- 不採用理由: ユーザー判断で「UserHash は Service 内に閉じる」方針を選択

### 代替案 2: `RecordFormatter` を全リソース汎用に拡張する

リソースごとに Formatter クラスを分けず、`RecordFormatter` に `format_category` / `format_payment_method` / `format_invoice` 等のメソッドを追加する。

- 短所: クラスが太り、責務が「全リソースの整形を知る神クラス」化する
- 不採用理由: ユーザー判断で「リソースごとに専用 Formatter クラスを作る」方針を選択

### 代替案 3: Entity を完全に「expose のみ」に固定し ISO8601 フォーマットも Service でやる

`format_with: :iso_timestamp` も Service で `to_s` 等で済ませる。

- 短所: 日付フォーマットは「JSON 表現の都合」であり、Service よりも Entity の責務として自然
- 不採用理由: ユーザー判断で「フォーマット変換のみ Entity に許容」を選択

## 未解決事項

- `InvoiceRecordFormatter#format` のシグネチャは実装時に詰める。`monthly_records` 用と `withdrawal_records_aggregation` 用で別メソッド名にするか、ひとつにまとめるかは Formatter 内の見通しを見て判断する
- `categories` / `payment_methods` の API spec が一部しか存在しないので、テスト追加範囲は実装時に「現状で互換性が担保できる最小範囲」を選ぶ

---

## 実装サマリー

> **実装日**: 2026-05-09

### 変更ファイル

- `api/lib/field_formatter.rb` — 新設（カラム単位の復号 / Constants ラベル参照を集約）
- `api/lib/finance_record_formatter.rb` — `record_formatter.rb` からリネーム + `FieldFormatter` 経由に書き換え
- `api/lib/category_formatter.rb` — 新設
- `api/lib/payment_method_formatter.rb` — 新設
- `api/lib/invoice_record_formatter.rb` — 新設（`monthly_records` 平坦化用 `format_monthly` メソッド）
- `api/services/categories.rb` — `CategoryFormatter` 経由に変更
- `api/services/payment_methods.rb` — `PaymentMethodFormatter` 経由に変更
- `api/services/invoice_records.rb` — `monthly_records` を平坦ハッシュ返しに変更、`InvoiceRecordFormatter` 利用、`require` 整理
- `api/services/records.rb` / `api/services/view.rb` — `FinanceRecordFormatter` への参照更新
- `api/app/api/v1/invoice_records.rb` — 33-45 の平坦化ロジックを削除し、Service 戻り値を直接 `present`
- `api/spec/lib/{field,finance_record,category,payment_method,invoice_record}_formatter_spec.rb` — 各 Formatter の spec
- `api/spec/lib/record_formatter_spec.rb` → `finance_record_formatter_spec.rb` にリネーム

### 実装内容

ddoc の方針通りに 6 ステップで進めた:

1. **Service 間結合の再検証**: `grep -rn "Service::" api/services/` で参照ゼロを確認。#50 で完全に解消済みだったため追加対応なし
2. **`FieldFormatter` 新設** (commit `58898fe`)
3. **`RecordFormatter` → `FinanceRecordFormatter` リネーム + `FieldFormatter` 経由化** (commit `bd5ef52`)
4. **`CategoryFormatter` 新設、`Service::Categories#all` 切替** (commit `a63399b`)
5. **`PaymentMethodFormatter` 新設、`Service::PaymentMethods#all` 切替** (commit `79f7af7`)
6. **`InvoiceRecordFormatter` 新設、`monthly_records` 平坦化を Service へ移動、API 層 33-45 削除** (commit `cc46f0d`)

その後、PR #64 のレビューフィードバック (commit `171cf36`) で `FieldFormatter` の API を以下に整理:

- `module` から `class` に変更し、`uhash` をインスタンス変数で保持（再利用可能化）
- `label` / `text` の 2 メソッドを `value(encrypted, default: nil)` に統合（差は nil 時のフォールバックだけだったため、呼び出し側で `default: TODO_LABEL` / `default: ""` を都度指定する形に）
- `constant_label` の引数を「Constants の lookup 結果」から「Constants のメソッド参照 + id」に変更し、呼び出し側を短縮（`@field.constant_label(Constants.method(:record_type), record[:record_type_id])`）

### 確認・検証

- `./scripts/test/api-test.sh` で全テストパス（32 examples, 0 failures）
- 既存の `categories_spec.rb` / `records_spec.rb` でレスポンス互換性を確認
- API レスポンスの形は変更なし（フロントエンド側の対応不要）

### 気づき・備考

- `InvoiceRecordFormatter` は `format_monthly` のみ実装。`withdrawal_records_aggregation` の整形は既存の `FinanceRecordFormatter` で十分賄えており、追加メソッドは不要だった。ddoc の「未解決事項」で予想したとおりの結果
- `FieldFormatter` を class 化したことで、各 Formatter が `@field = FieldFormatter.new(uhash:)` を保持する二段構成になった。コンストラクタ引数が同じため違和感はないが、Formatter が増えたときに「FieldFormatter を継承させてもよいのでは」という議論は将来生じる可能性がある（今回はその必要を感じなかったため見送り）
- レビューで指摘された「`label` と `text` の差は default だけ」という観察は鋭く、最初から `value` 1 本にしておくのが筋だった。今後、似たヘルパーを増やすときは「差分が引数で吸収できないか」をまず検討する
