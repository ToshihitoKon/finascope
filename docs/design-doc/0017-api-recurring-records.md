# 0017 recurring records API

> **scope**: api, db | **date**: 2026-06-14

## 概要

`recurring_records` テーブルを新設し、繰り返しレコードの定義を管理する。ログイン時に未生成月の `finance_records` を自動生成する仕組みと、手動で翌月分を生成するエンドポイントを追加する。また `finance_records` に `recurring_group_id` を追加して繰り返しグループと紐付ける。

## 目標

- `recurring_records` テーブルで繰り返し定義を CRUD できる
- ログイン時に当月までの未生成分の `finance_records` を自動生成する
- 手動で任意月の `finance_records` を生成するエンドポイントを持つ
- `finance_records` の作成・更新時に `recurring_group_id` を指定できる
- recurring フラグで絞り込む GET エンドポイントを追加する

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
t_def.date    :end_date,           null: true   # 繰り返し終了月 (null: 無期限)
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
  "end_date": null
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
      "end_date": null,
      "record_type_id": 1,
      "state_id": 1,
      "category_id": "cat_xxx",
      "payment_method_id": "pm_xxx"
    }
  ]
}
```

#### 月次生成エンドポイント

| メソッド | パス | 説明 |
|---------|------|------|
| POST | /api/v1/recurring_records/generate | 指定月の finance_records を生成 |

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
  "generated_count": 3,
  "records": [{ "id": "fr_xxx", "status": "created" }]
}
```

既に同 `recurring_group_id` + 同月のレコードが存在する場合はスキップ（冪等）。

#### finance_records の変更

- POST/PUT に `recurring_group_id` パラメータ（optional）を追加
- GET に `recurring` フィルタパラメータを追加

```
GET /api/v1/records?recurring=true
```

#### ログイン時自動生成

`request_userdata` が呼ばれた後（認証成功後）、`RecurringRecordGenerator` サービスを呼んで当月までの未生成分を生成する。処理はバックグラウンドではなく同期的に行う（件数が少ない前提）。

生成済み判定: `finance_records` に同じ `recurring_group_id` かつ同月（year + month が一致）のレコードが存在すれば生成済み。生成時の日付は月初（1日）で統一する。

### Entity

`API::Entities::RecurringRecords::RecurringRecord` を新規作成。

## 変更ファイル一覧

- `api/db/models.rb` — `RecurringRecord` モデル追加、`FinanceRecord` に `recurring_group_id` カラム追加
- `api/db/repositories.rb` — `RecurringRecord` リポジトリ追加、`FinanceRecord` リポジトリに `recurring_group_id` フィルタ・`recurring` フィルタ追加
- `api/services/recurring_records.rb` — 新規。RecurringRecord の CRUD サービス
- `api/services/recurring_record_generator.rb` — 新規。月次生成ロジック（未生成月を検出して finance_records を生成）
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
4. `api/services/recurring_records.rb` を新規作成（CRUD）
5. `api/services/recurring_record_generator.rb` を新規作成（月次生成ロジック）
6. `api/services/records.rb` を更新（`recurring_group_id` / `recurring` フィルタ対応）
7. `api/app/api/v1/entities/recurring_records.rb` を新規作成
8. `api/app/api/v1/recurring_records.rb` を新規作成（CRUD + generate エンドポイント）
9. `api/app/api/v1/records.rb` を更新（パラメータ追加）
10. `api/app/api/v1/root.rb` と `api/app/api/root.rb` を更新（mount / swagger 登録）
11. `api/app/api/root.rb` の `request_userdata` ヘルパーにログイン時自動生成を追加
12. spec を追加・更新してテストを通す

## 代替案

- **finance_records に recurring 定義を直接持たせる**: 現行の `recurring` boolean フラグがこれに相当する。グループ連動や自動生成ができないため今回は採用しない。
- **バックグラウンドジョブ（Cron）で自動生成**: インフラ変更が必要で scope が大きくなるため、ログイン時生成を採用する。

## 未解決事項

- `end_date` を超えた recurring_record の扱い: 生成時にスキップするが、deleted_at を立てるかは今後判断
