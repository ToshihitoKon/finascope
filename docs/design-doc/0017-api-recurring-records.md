# 0017 recurring records API

> **scope**: api, db | **date**: 2026-06-14

## 概要

`recurring_records` テーブルを新設し、繰り返しレコードの定義を管理する。指定月 + 指定 recurring_id で `finance_records` を生成するエンドポイントを追加する。また `finance_records` に `recurring_group_id` を追加して繰り返しグループと紐付ける。

## 目標

- `recurring_records` テーブルで繰り返し定義を CRUD できる
- 指定月 + 指定 recurring_id で `finance_records` を生成するエンドポイントを持つ
- `finance_records` の作成・更新時に `recurring_group_id` を指定できる
- `recurring_group_id` の有無で絞り込む GET エンドポイントを追加する

## 非目標

- フロントエンド UI（別 ddoc で対応）
- recurring_records のグループ単位一括編集（今回は定義の CRUD のみ）

## 設計

### データモデル

**recurring_records テーブル（新規）**

```ruby
t_def.string  :id,                 null: false, primary_key: true
t_def.string  :hashed_user_id,     null: false
t_def.integer :record_type_id,     null: false
t_def.integer :state_id,           null: false
t_def.string  :encrypted_title,    null: false
t_def.integer :amount,             null: false
t_def.string  :category_id,        null: false
t_def.string  :payment_method_id,  null: false
t_def.string  :encrypted_description, null: true
t_def.date    :start_date,         null: false  # 繰り返し開始月
t_def.integer :total_count,        null: true   # 支払い総回数 (null: 無期限)
t_def.datetime :deleted_at,        null: true
t_def.timestamps null: false
```

インデックス: `hashed_user_id`, `category_id`, `payment_method_id`

**finance_records テーブル（変更）**

```ruby
# 既存カラムに追加
t_def.string :recurring_group_id, null: true  # recurring_records.id を参照
```

インデックス: `recurring_group_id`

### API 設計

#### recurring_records CRUD

| メソッド | パス | 説明 |
|---------|------|------|
| GET | /api/v1/recurring_records | 繰り返し定義一覧取得 |
| POST | /api/v1/recurring_records | 繰り返し定義作成 |
| PUT | /api/v1/recurring_records/:id | 繰り返し定義更新 |
| DELETE | /api/v1/recurring_records/:id | 繰り返し定義削除 |

**POST /api/v1/recurring_records リクエスト:**
```json
{
  "title": "Netflix",
  "type_id": 1,
  "state_id": 1,
  "description": "",
  "amount": 1980,
  "category_id": "cat_xxx",
  "payment_method_id": "pm_xxx",
  "start_date": "2026-06-01",
  "total_count": null
}
```

**GET /api/v1/recurring_records レスポンス:**
```json
{
  "recurring_records": [
    {
      "id": "rr_xxx",
      "title": "Netflix",
      "type": "支出",
      "amount": 1980,
      "state": "確定",
      "category": "サブスク",
      "payment_method": "クレジットカード",
      "start_date": "2026-06-01",
      "total_count": null,
      "generated_count": 1,
      "record_type_id": 1,
      "state_id": 1,
      "category_id": "cat_xxx",
      "payment_method_id": "pm_xxx"
    }
  ]
}
```

#### 月次生成エンドポイント

指定月 + 指定 recurring_id の組み合わせで `finance_records` を 1 件生成する。

| メソッド | パス | 説明 |
|---------|------|------|
| POST | /api/v1/recurring_records/:id/generate | 指定 recurring_id・指定月の finance_record を生成 |

**リクエスト:**
```json
{
  "year": 2026,
  "month": 7
}
```

**レスポンス:**
```json
{
  "status": "created",
  "id": "fr_xxx"
}
```

既に同 `recurring_group_id` + 同月のレコードが存在する場合は HTTP 409 を返す（冪等ではなく明示的エラー）。

#### finance_records の変更

- POST/PUT に `recurring_group_id` パラメータ（optional）を追加
- GET に `recurring` フィルタパラメータを追加（`recurring_group_id IS NOT NULL` で絞り込む）

```
GET /api/v1/records?recurring=true
```

**ログイン時の自動生成**: ユーザーが API を呼び出すたびに `request_userdata` 内で `auto_generate_current_month` を実行し、今月分の `finance_records` を自動生成する。generate エンドポイントは手動で特定月のレコードを生成したい場合に使用する。

#### 生成済み判定の on-memory cache

`auto_generate_current_month`（ログイン時フック）内で `ActiveSupport::Cache::MemoryStore` をプロセスグローバルなキャッシュとして使用する。月イチ程度の更新頻度なので TTL は 30 日に設定する。ActiveSupport はすでに ActiveRecord 経由で依存済みのため追加コストなし。

generate エンドポイント（手動生成）は DB を直接参照して存在確認を行う（キャッシュは使用しない）。

```ruby
CACHE = ActiveSupport::Cache::MemoryStore.new

# auto_generate_current_month 内: キャッシュが存在すればスキップ
key = "#{hashed_user_id}-#{recurring_group_id}-#{year}-#{month}"
next if CACHE.read(key)
next if DB::Repository::FinanceRecord.exists_in_month?(recurring_group_id:, year:, month:)
# 生成後にキャッシュに書き込む
CACHE.write(key, true, expires_in: 30.days)
```

### Entity

`API::Entities::RecurringRecords::RecurringRecord` を新規作成。

## 変更ファイル一覧

- `api/db/models.rb` — `RecurringRecord` モデル追加、`FinanceRecord` に `recurring_group_id` カラム追加
- `api/db/repositories.rb` — `RecurringRecord` リポジトリ追加、`FinanceRecord` リポジトリに `recurring_group_id` フィルタ・`recurring` フィルタ追加
- `api/services/recurring_records.rb` — 新規。RecurringRecord の CRUD + generate サービス
- `api/services/records.rb` — `create` / `update` に `recurring_group_id` パラメータ追加、`get_records` に `recurring` フィルタ追加
- `api/app/api/v1/recurring_records.rb` — 新規。CRUD + generate エンドポイント
- `api/app/api/v1/records.rb` — GET に `recurring` param 追加、POST/PUT に `recurring_group_id` param 追加
- `api/app/api/v1/entities/recurring_records.rb` — 新規。`RecurringRecord` エンティティ
- `api/app/api/v1/root.rb` — `RecurringRecords` を mount
- `api/app/api/root.rb` — swagger の `models:` に `RecurringRecord` エンティティ追加
- `api/spec/api/v1/recurring_records_spec.rb` — 新規。CRUD + generate の spec
- `api/spec/api/v1/records_spec.rb` — `recurring_group_id` / `recurring` フィルタのテスト追加
- `mysql/init.d/00_user_database.sql` — `recurring_records` テーブル DDL 追加、`finance_records` に `recurring_group_id` カラム追加

## 実装ステップ

1. `mysql/init.d/00_user_database.sql` に `recurring_records` テーブルと `finance_records.recurring_group_id` カラムを追加する
2. `api/db/models.rb` に `RecurringRecord` モデルを追加し、`FinanceRecord` に `recurring_group_id` を追加する
3. `api/db/repositories.rb` に `RecurringRecord` リポジトリを追加し、`FinanceRecord` リポジトリを更新する
4. `api/services/recurring_records.rb` を新規作成（CRUD + generate ロジック）
5. `api/services/records.rb` を更新（`recurring_group_id` / `recurring` フィルタ対応）
7. `api/app/api/v1/entities/recurring_records.rb` を新規作成
7. `api/app/api/v1/recurring_records.rb` を新規作成（CRUD + generate エンドポイント）
8. `api/app/api/v1/records.rb` を更新（パラメータ追加）
9. `api/app/api/v1/root.rb` と `api/app/api/root.rb` を更新（mount / swagger 登録）
10. spec を追加・更新してテストを通す

## 代替案

- **finance_records に recurring 定義を直接持たせる**: 現行の `recurring` boolean フラグがこれに相当する。グループ連動や自動生成ができないため今回は採用しない。
- **バックグラウンドジョブ（Cron）で自動生成**: インフラ変更が必要で scope が大きくなるため、ログイン時生成を採用する。

## 未解決事項

- `total_count` に達した recurring_record の扱い: generate 時に 409 を返すが、`deleted_at` を立てるかは今後判断

---

## 実装サマリー

> **実装日**: 2026-06-14

### 変更ファイル

- `api/db/models.rb` — `RecurringRecord` モデル追加（`end_date` Generated Column 含む）、`FinanceRecord` に `recurring_group_id` カラム追加（`recurring` boolean は削除）
- `api/db/utils.rb` — `TableColumns` に nullable カラム追跡機能を追加（`null:` キーワード引数）
- `api/db/basewrapper.rb` — DTO の `invalid_members` で nullable カラムを除外するよう修正
- `api/db/repositories/recurring_records.rb` — 新規。`all(year:, month:)` フィルタ付き、`find`, `generated_count` メソッド
- `api/db/repositories/finance_records.rb` — `get_page` に `recurring:` フィルタ追加、`exists_in_month?` 追加
- `api/db/repositories.rb` — `recurring_records` リポジトリの require 追加
- `api/lib/exceptions.rb` — `Exceptions::Conflict`（HTTP 409）追加
- `api/services/recurring_records.rb` — 新規。CRUD + `generate` + `auto_generate_current_month`（all_done キャッシュ最適化含む）
- `api/services/records.rb` — `recurring_group_id` パラメータ対応、`recurring` フィルタ追加
- `api/app/api/v1/recurring_records.rb` — 新規。CRUD + `POST :id/generate` エンドポイント
- `api/app/api/v1/records.rb` — `recurring` / `recurring_group_id` パラメータ追加
- `api/app/api/v1/entities/recurring_records.rb` — 新規。`RecurringRecord` エンティティ（`end_date` expose 含む）
- `api/app/api/v1/entities/records.rb` — `recurring_group_id` expose に変更
- `api/app/api/v1/root.rb` — `RecurringRecords` を mount
- `api/app/api/root.rb` — swagger の `models:` 追加、`request_userdata` に `auto_generate_current_month` フック追加
- `api/spec/api/v1/recurring_records_spec.rb` — 新規。CRUD + generate + 409 ケースの spec
- `api/spec/api/v1/records_spec.rb` — `recurring_group_id` / `recurring` フィルタのテスト更新

### 実装内容

ddoc の設計に沿って実装した。PR レビューで複数の改善を加えた。主な差分は以下:

- **ログイン時フックの追加**: ddoc 途中で「ログイン時の自動生成は行わない」と誤記していたが、実装では `request_userdata` 内で `auto_generate_current_month` を呼ぶ形で実装した。これは当初から意図されていた設計（削除されたのは Cron ジョブのみ）。
- **generate はキャッシュ不使用**: generate エンドポイントは DB を直接参照して重複確認を行う。
- **auto_generate のキャッシュ最適化**: per-record のキャッシュから `userid + year + month` の all_done フラグに変更。全件処理済みなら次回ログイン時は即 early return。TTL は 1 時間。新規 recurring 作成時にキャッシュを invalidate。
- **`total_count` 判定の最適化**: `generated_count` DB クエリを廃止し、`start_date` からの経過月数計算に置き換え。`RecurringRecord.all` に `year/month` フィルタを追加し SQL レベルで有効な recurring のみ取得。
- **`end_date` Generated Column の追加**: フィルタクエリ簡略化とフロント表示のため、`STORED` Generated Column として追加。`DATE_ADD(start_date, INTERVAL (total_count - 1) MONTH)` で自動算出、アプリからの書き込み不可。
- **nullable カラムの DTO validation 問題**: `recurring_group_id` と `encrypted_description` が nullable にもかかわらず `validate!` が 422 を返すバグを修正。`TableColumns` に `null:` 追跡を追加し `invalid_members` で除外。

### 確認・検証

`./scripts/test/api-test.sh` で全 60 テスト通過を確認。

### 気づき・備考

- `auto_generate_current_month` がテスト時にも実行されるため（spec の認証フックから呼ばれる）、generate の spec では current month は auto_generate 済みを前提に next month を対象とする設計が必要だった。テスト前に `CACHE.clear` を入れることで各テストが独立するよう対処。
- `end_date` Generated Column は ActiveRecord の `t.virtual` で定義。`TableColumns#method_missing` がキャッチし nullable として扱われる。
- `TableColumns#method_missing` が `null: true` をデフォルトに持つことで、既存モデルの nullable 設定が自動的に引き継がれる（後方互換性を維持）。
