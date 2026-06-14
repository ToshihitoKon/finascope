# 0018 recurring records frontend

> **scope**: front | **date**: 2026-06-14

## 概要

明細テーブルに recurring バッジを追加し、新規作成フォームで recurring フラグと `recurring_group_id` を指定できるようにする。また recurring レコードのみ絞り込むフィルタ UI を追加する。

## 目標

- 明細テーブルの各行に recurring バッジを表示する
- 新規作成フォームで recurring フラグを ON/OFF できる
- 新規作成フォームで `recurring_group_id`（繰り返し定義）を選択できる
- recurring フラグでレコードを絞り込むフィルタ UI を追加する

## 非目標

- recurring records 専用ページ（エンドポイントが整備され次第、別途実装）
- 既存レコードのインライン編集（現状テーブルは閲覧のみ）

## 前提

ddoc 0017 の API が実装済みであること。具体的には以下が利用可能であること。
- `GET /api/v1/records?recurring=true` — recurring フィルタ
- `GET /api/v1/recurring_records` — 繰り返し定義一覧
- `POST /api/v1/records` に `recurring_group_id` パラメータが追加済み

## 設計

### コンポーネント構成

既存の `ExpenseDetails.svelte` を修正する。新規コンポーネントは作らない。

**変更内容:**

1. **recurring バッジ**: 各行の用途列（`layout-title`）の横、または先頭チェックボックス列の隣にバッジを表示する。`record.recurring === true` の場合のみ表示する。
   - バッジテキスト: 「定期」
   - スタイル: 小さいラベル、primary カラーの枠線

2. **新規作成フォーム — recurring チェックボックス**: テーブル末尾の新規入力行に recurring チェックボックスを追加する。列は既存の末尾（追加ボタン列の手前）に挿入する。

3. **新規作成フォーム — recurring_group_id セレクト**: recurring チェックボックスが ON の場合のみ表示するセレクトを追加する。繰り返し定義一覧（`GET /api/v1/recurring_records`）から選択肢を生成する。

4. **recurring フィルタ**: テーブルヘッダー上部に「定期のみ表示」トグルを追加する。ON の場合、`GET /api/v1/records` に `recurring=true` を付与して再取得する。

### 状態管理

`ExpenseDetails.svelte` に以下の状態を追加する。

```typescript
let newRecurring = $state<boolean>(false);
let newRecurringGroupId = $state<string | undefined>(undefined);
let recurringRecords = $state<RecurringRecord[]>([]);
let filterRecurring = $state<boolean>(false);
```

`onMount` 時に `api.fetchRecurringRecords()` で繰り返し定義一覧を取得する。

`filterRecurring` が変化したとき（`$effect`）、`loadRecords` に `recurring` フィルタを渡す。

### API クライアント変更

- `front/src/lib/api/v1/types.d.ts` — `RecurringRecord` 型、`RecurringRecordsResponse` 型、`CreateRecordRequest` / `UpdateRecordRequest` に `recurring_group_id?: string` を追加
- `front/src/lib/api/v1/api.ts` — `fetchRecurringRecords()` 関数を追加、`fetchRecords` に `recurring` オプションパラメータを追加

### UI イメージ

```
[ 定期のみ表示 □ ]

| □ | 日付 | 種別 | 金額 | カテゴリ | 支払方法 | 状態 | 用途         |   |
|---|------|------|------|----------|----------|------|--------------|---|
| □ | 6/1  | 支出 | ¥1,980 | サブスク | クレジット | 確定 | Netflix [定期] |   |
| □ | 6/15 | 支出 | ¥500 | 食費     | 現金      | 確定 | コーヒー      |   |
| □ |新規入力行... | [□定期] [定義選択▼] | [追加] |
```

## 変更ファイル一覧

- `front/src/lib/api/v1/types.d.ts` — `RecurringRecord`, `RecurringRecordsResponse` 型追加、`CreateRecordRequest` / `UpdateRecordRequest` に `recurring_group_id?: string` 追加、`fetchRecords` の引数型に `recurring?: boolean` 追加
- `front/src/lib/api/v1/api.ts` — `fetchRecurringRecords()` 追加、`fetchRecords` に `recurring` パラメータ追加
- `front/src/lib/components/ExpenseDetails.svelte` — recurring バッジ、フォームの recurring チェックボックス + recurring_group_id セレクト、filterRecurring トグル追加

## 実装ステップ

1. `types.d.ts` に `RecurringRecord` / `RecurringRecordsResponse` 型を追加し、既存リクエスト型に `recurring_group_id` を追加する
2. `api.ts` に `fetchRecurringRecords()` を追加し、`fetchRecords` に `recurring` フィルタを追加する
3. `ExpenseDetails.svelte` に `filterRecurring` トグルと `loadRecords` への反映を追加する
4. `ExpenseDetails.svelte` の各行に recurring バッジを追加する（表示のみ）
5. `ExpenseDetails.svelte` の新規入力行に recurring チェックボックスと recurring_group_id セレクトを追加し、`handleCreate` に反映する
6. `pnpm svelte-check` / `pnpm eslint` / `pnpm lint:style` をパスさせる

## 未解決事項

- recurring_group_id セレクトに「なし」オプションを含めるかどうか（recurring=true でも group 未指定を許容するか）
- バッジの配置列（用途列内に inline で置くか、専用列を追加するか）
