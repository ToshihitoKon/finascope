# 0015 Entity 層の module/class 揺れ・ネスト構造の統一

> **scope**: api | **date**: 2026-05-09

## 概要

`api/app/api/v1/entities/` 配下のエンティティファイルにおける外側コンテナの形式（`module` vs `class`）と、リソース名コンテナの有無を統一する。命名規則を Design Doc とプロジェクトドキュメントに明文化し、新規 Entity 追加時の判断基準を残す。

関連 issue: [#53](https://github.com/ToshihitoKon/finascope/issues/53)

## 目標

- すべての Entity ファイルで「外側コンテナを `module`、内側に `Grape::Entity` を継承した `class` を入れ子にする」構造に統一する
- `common.rb` を例外扱いせず、他ファイルと同じ「リソース名 module でラップ」パターンに揃える
- 命名規則を `CLAUDE.md` または `api/app/api/v1/entities/` の README に明文化する
- 全テスト（rspec）・Swagger ドキュメント生成が変更前後で動作することを確認する

## 非目標

- Entity の expose プロパティの追加・削除・リネーム
- Entity 内部クラスのリネーム（`Records::Record`, `InvoiceRecords::InvoiceRecord` など現状維持）
- Service 層 / Repository 層への波及的なリファクタ（範囲は entities + 参照側のみ）
- Entity 層の責務再設計（issue #51 / PR #64 で完了済み）

## 設計

### 統一後の規約

すべての Entity は以下の構造に従う:

```ruby
module API
  module Entities
    module <ResourceNamePlural>           # 外側コンテナは module、リソース名の複数形
      class <EntityName> < Grape::Entity  # 内側は Grape::Entity を継承した class
        expose :id, ...
      end
    end
  end
end
```

#### 命名規則

| 項目 | ルール | 例 |
|------|-------|----|
| ファイル名 | リソース名の複数形（snake_case） | `categories.rb`, `invoice_records.rb` |
| 外側コンテナ | `module` + リソース名の複数形（PascalCase） | `module Categories`, `module InvoiceRecords` |
| 内側 Entity クラス | `class` + 単数形 or 用途別の名前 | `Category`, `InvoiceRecord`, `WithdrawalRecordsAggregation` |

#### 共通レスポンス（Common）の扱い

リソースに紐づかない汎用 Entity も同じパターンで揃える。

- ファイル名: `common.rb`
- 外側コンテナ: `module Common`
- 内側クラス: `class Response`（既存の `CommonResponse` をリネーム）
- 参照パス: `API::Entities::Common::Response`

### 変更対象一覧

| ファイル | 変更前 | 変更後 |
|---------|-------|-------|
| `entities/categories.rb` | `module Categories` | 変更なし |
| `entities/payment_methods.rb` | `module PaymentMethods` | 変更なし |
| `entities/records.rb` | `module Records` | 変更なし |
| `entities/view.rb` | `module View` | 変更なし |
| `entities/invoice_records.rb` | **`class InvoiceRecords`** | `module InvoiceRecords` |
| `entities/common.rb` | `class CommonResponse`（直下） | `module Common` + `class Response` |

`module` と `class` は定数として同じパスで参照できるため、`InvoiceRecords` の `class → module` 変更単独では参照側の書き換えは不要。一方 `Common` のラップ化は `API::Entities::CommonResponse` → `API::Entities::Common::Response` への定数パス変更を伴うため、参照側全箇所を書き換える。

### 参照書き換え対象（`CommonResponse` のみ）

以下 21 箇所を `API::Entities::CommonResponse` → `API::Entities::Common::Response` に置換する:

- `api/app/api/root.rb:53` — Swagger 登録
- `api/app/api/v1/invoice_records.rb` — 6 箇所（L37, L63, L67, L94, L98, L110）
- `api/app/api/v1/payment_methods.rb` — 4 箇所（L27, L49, L53, L79）
- `api/app/api/v1/categories.rb` — 4 箇所（L25, L41, L45, L67）
- `api/app/api/v1/records.rb` — 6 箇所（L39, L72, L76, L112, L116, L129）

機械的な全置換で対応可能（変更前後で意味的差分なし）。

### ドキュメント更新

`CLAUDE.md` の「ディレクトリ構成」セクション内、`api/` の「API エンドポイント追加」近辺に以下の規約を追記する:

```markdown
### Entity 層の命名規則

`api/app/api/v1/entities/` 配下に Entity を追加する際は以下に従う:

- 外側コンテナは `module ResourceNamePlural`（リソース名の複数形）で定義する
- 内側で `class EntityName < Grape::Entity` を定義する
- 共通レスポンスなどリソースに紐づかない Entity も `module Common` のようにラップする

例:
\`\`\`ruby
module API
  module Entities
    module Categories
      class Category < Grape::Entity
        expose :id
        expose :label
      end
    end
  end
end
\`\`\`
```

## 変更ファイル一覧

実装時に変更が必要なファイル:

- `api/app/api/v1/entities/invoice_records.rb` — 外側を `class InvoiceRecords` から `module InvoiceRecords` に変更
- `api/app/api/v1/entities/common.rb` — `class CommonResponse` を `module Common` + `class Response` に書き換え
- `api/app/api/root.rb` — Swagger 登録の `API::Entities::CommonResponse` を `API::Entities::Common::Response` に変更
- `api/app/api/v1/invoice_records.rb` — `CommonResponse` 参照 6 箇所を置換
- `api/app/api/v1/payment_methods.rb` — `CommonResponse` 参照 4 箇所を置換
- `api/app/api/v1/categories.rb` — `CommonResponse` 参照 4 箇所を置換
- `api/app/api/v1/records.rb` — `CommonResponse` 参照 6 箇所を置換
- `CLAUDE.md` — Entity 命名規則セクション追加
- `api/spec/api/v1/` — `CommonResponse` を直接参照している spec があれば追従（要確認）

## 実装ステップ

1. **invoice_records.rb の class→module 変更**
   - `entities/invoice_records.rb` の外側を `class` から `module` に変更
   - 参照側の書き換えは不要（定数パスは変わらない）
   - rspec を実行して全テストパスを確認
   - 単独コミット: `refactor(api): unify InvoiceRecords entity container to module`

2. **Common モジュールへのラップ**
   - `entities/common.rb` を `module Common` + `class Response` 構造に書き換え
   - `grep -rn "API::Entities::CommonResponse" api/` で抽出した 21 箇所を `API::Entities::Common::Response` に一括置換
   - spec 内に `CommonResponse` 参照があれば同様に置換
   - rspec を実行して全テストパス・Swagger 生成を確認
   - 単独コミット: `refactor(api): wrap CommonResponse with Common module namespace`

3. **CLAUDE.md にドキュメント追加**
   - Entity 層の命名規則セクションを追記
   - 単独コミット: `docs: add entity naming convention to CLAUDE.md`

4. **PR 作成と issue クローズ**
   - PR description に `Closes: #53` を記載
   - レビュー後マージ → `/update-issue-dependencies` 実行

## 代替案

### A. 全 Entity をフラット配置（`API::Entities::Category` 形式）

`common.rb` の現状形式（コンテナなし）に他ファイルを揃える案。

- 採用しなかった理由: 5 ファイル中 4 ファイルで `module ResourceNamePlural` 構造を採用しており、変更コストとコンフリクト面積が大きい。`Records::Record` など既存命名は外側コンテナの存在を前提としており、フラット化すると `Record` のような汎用名の衝突リスクがある

### B. 外側を全 `class` に統一

`InvoiceRecords` の現状形式（`class`）に他ファイルを揃える案。

- 採用しなかった理由: namespace 用途で `class` を使う Ruby 慣習は薄い。インスタンス化されない単なる名前空間に `class` を使うとリーダーに「クラスメソッドや継承があるのか」と誤解させる

### C. Common はそのまま（コンテナなしを例外として明文化）

`API::Entities::CommonResponse` を維持し、Design Doc で「リソース非依存のため例外」と明記する案。

- 採用しなかった理由: 「例外」を許容すると次に追加される共通 Entity がどう振る舞うべきか判断材料を残すコストが残り続ける。21 箇所の機械置換は一度きりのコストで、以降は完全な一貫性が得られる

## 未解決事項

- `api/spec/` 内に `CommonResponse` 直接参照があるかは Step 2 で `grep` 確認後に追加対応する（無ければスキップ）
- `entities/` 配下の README を新規作成するか、`CLAUDE.md` のみで済ませるかは実装時に判断（推奨は CLAUDE.md のみで集約）

---

## 実装サマリー

> **実装日**: 2026-05-09

### 変更ファイル

- `api/app/api/v1/entities/invoice_records.rb` — 外側を `class InvoiceRecords` から `module InvoiceRecords` に変更
- `api/app/api/v1/entities/common.rb` — `class CommonResponse` を `module Common` + `class Response` に書き換え
- `api/app/api/root.rb` — Swagger 登録の参照を `API::Entities::Common::Response` に変更
- `api/app/api/v1/categories.rb` — `CommonResponse` 参照 4 箇所を置換
- `api/app/api/v1/invoice_records.rb` — `CommonResponse` 参照 6 箇所を置換
- `api/app/api/v1/payment_methods.rb` — `CommonResponse` 参照 4 箇所を置換
- `api/app/api/v1/records.rb` — `CommonResponse` 参照 6 箇所を置換
- `CLAUDE.md` — Entity 命名規則セクション追加

### 実装内容

ddoc の設計通り、3 ステップに分けて単独コミットで実施:

1. `entities/invoice_records.rb` の外側コンテナを `class` から `module` に変更（commit `3a093ad`）。`module` と `class` は定数として同じパスで参照できるため、参照側の書き換えは不要で 1 行差分のみで完了
2. `entities/common.rb` を `module Common` + `class Response` 構造にラップし、`API::Entities::CommonResponse` 参照 21 箇所を `API::Entities::Common::Response` に一括置換（commit `d404ec4`）。`sed` による機械置換で対応
3. `CLAUDE.md` の `### API 構造` セクション直後に「Entity 層の命名規則」セクションを追記（commit `cc87e67`）。Swagger 登録忘れ防止の注意書きも併せて追加

ddoc からの逸脱はなし。

### 確認・検証

- Step 1 / Step 2 完了後に `./scripts/test/api-test.sh` を実行 → **32 examples, 0 failures**
- `grep -rn "CommonResponse" api/ --include="*.rb"` で残存参照ゼロを確認
- 全 Entity ファイルが `module ResourceNamePlural + class EntityName < Grape::Entity` の統一構造になっていることを最終確認

### 気づき・備考

- ddoc の未解決事項に挙げていた「`api/spec/` 内の `CommonResponse` 直接参照」は調査の結果ゼロで、追加対応は不要だった
- `entities/` 配下の README は作らず CLAUDE.md に集約する方針を採用。エンジニアが Entity を追加する際の参照導線として、プロジェクト全体ガイドの `CLAUDE.md` 一箇所にまとめたほうが見落としにくい
- Step 1 の `class → module` は定数パスが不変のため参照側書き換えゼロで済む、という ddoc の見立てが実装でも実証された。今後同様の「外側コンテナの形式変更のみ」を行う場合の参考になる
