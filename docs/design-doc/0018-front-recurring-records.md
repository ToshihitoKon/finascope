# 0018 recurring records frontend

> **scope**: front | **date**: 2026-06-14

## 概要

明細テーブルに recurring アイコンを追加し、新規作成フォームで `recurring_group_id` を指定できるようにする。recurring_records を操作する専用テーブルコンポーネントと作成・編集フォームを追加する。また recurring レコードのみ絞り込むフィルタ UI を追加する。

## 目標

- 明細テーブルの各行に `recurring_group_id` を持つレコードへ repeat アイコンを表示する
- 新規作成フォームで `recurring_group_id`（繰り返し定義）を選択できる
- `recurring_group_id` を持つ finance_records のインライン編集ができる
- recurring_records を操作する専用テーブルコンポーネントを追加する（CRUD + generate）
- recurring_records の作成・編集に使う専用フォームコンポーネントを追加する
- recurring フラグでレコードを絞り込むフィルタ UI を追加する

## 非目標

- recurring records 専用ページ（コンポーネントを用意するが、ルーティングは今後）

## 前提

ddoc 0017 の API が実装済みであること。具体的には以下が利用可能であること。
- `GET /api/v1/records?recurring=true` — recurring フィルタ
- `GET /api/v1/recurring_records` — 繰り返し定義一覧
- `POST /api/v1/records` に `recurring_group_id` パラメータが追加済み

## 設計

### コンポーネント構成

**新規コンポーネント:**

- `RecurringRecordForm.svelte` — recurring_record の作成・編集フォーム。作成時は POST、編集時は PUT を呼ぶ。同じフォームを両用する。
- `RecurringRecordsTable.svelte` — recurring_records の一覧テーブル。各行に編集・削除ボタンと「この月分を生成」ボタンを持つ。

**既存コンポーネントの変更（`ExpenseDetails.svelte`）:**

1. **repeat アイコン**: `recurring_group_id` を持つ行の用途列（`layout-title`）に Font Awesome の repeat アイコン（`fa-rotate` 等）を表示する。
   - アイコンは `@fortawesome/free-solid-svg-icons` から取得する。未導入の場合は SVG インライン or Unicode 代替（↻）で対応する。

2. **新規作成フォーム — recurring_group_id セレクト**: テーブル末尾の新規入力行に recurring_group_id セレクトを追加する。「なし」オプションを先頭に置き、繰り返し定義一覧（`GET /api/v1/recurring_records`）から選択肢を生成する。

3. **インライン編集**: `recurring_group_id` を持つ行も通常行と同じインライン編集が可能。`PUT /api/v1/records/:id` に `recurring_group_id` を含めて送信する。

4. **recurring フィルタ**: テーブルヘッダー上部に「定期のみ表示」トグルを追加する。ON の場合、`GET /api/v1/records` に `recurring=true` を付与して再取得する。

### 状態管理

`ExpenseDetails.svelte` に以下の状態を追加する。

```typescript
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

**ExpenseDetails（明細テーブル）:**
```
[ 定期のみ表示 □ ]

| □ | 日付 | 種別 | 金額 | カテゴリ | 支払方法 | 状態 | 用途            |   |
|---|------|------|------|----------|----------|------|-----------------|---|
| □ | 6/1  | 支出 | ¥1,980 | サブスク | クレジット | 確定 | ↻ Netflix     |   |
| □ | 6/15 | 支出 | ¥500 | 食費     | 現金      | 確定 | コーヒー         |   |
| □ | 新規入力行... | [定義選択▼] | [追加] |
```

**RecurringRecordsTable:**
```
| タイトル  | 金額   | カテゴリ | 開始月   |          |
|---------|--------|----------|---------|----------|
| Netflix | ¥1,980 | サブスク  | 2026/06 | [編集][削除][今月分生成] |
| 新規作成行 → RecurringRecordForm を表示 |
```

## 変更ファイル一覧

- `front/src/lib/api/v1/types.d.ts` — `RecurringRecord`, `RecurringRecordsResponse`, `CreateRecurringRecordRequest`, `UpdateRecurringRecordRequest`, `GenerateRecurringRecordRequest` 型追加、`CreateRecordRequest` / `UpdateRecordRequest` に `recurring_group_id?: string` 追加
- `front/src/lib/api/v1/api.ts` — `fetchRecurringRecords()`, `createRecurringRecord()`, `updateRecurringRecord()`, `deleteRecurringRecord()`, `generateRecurringRecord()` 追加、`fetchRecords` に `recurring` パラメータ追加
- `front/src/lib/components/RecurringRecordForm.svelte` — 新規。recurring_record の作成・編集フォーム
- `front/src/lib/components/RecurringRecordsTable.svelte` — 新規。recurring_records の一覧テーブル（CRUD + generate）
- `front/src/lib/components/index.ts` — 上記 2 コンポーネントをエクスポート追加
- `front/src/lib/components/ExpenseDetails.svelte` — repeat アイコン表示、recurring_group_id セレクト、インライン編集対応、filterRecurring トグル追加

## 実装ステップ

1. `types.d.ts` に RecurringRecord 関連の型を追加する
2. `api.ts` に RecurringRecord 関連の API 関数を追加し、`fetchRecords` に `recurring` フィルタを追加する
3. `RecurringRecordForm.svelte` を新規作成する（作成・編集の両モードに対応）
4. `RecurringRecordsTable.svelte` を新規作成する（CRUD + generate ボタン）
5. `index.ts` に新規コンポーネントをエクスポート追加する
6. `ExpenseDetails.svelte` を更新する（アイコン表示、recurring_group_id セレクト、インライン編集、フィルタ）
7. `pnpm svelte-check` / `pnpm eslint` / `pnpm lint:style` をパスさせる

## 未解決事項

- Font Awesome が未導入の場合のアイコン代替手段（SVG インライン or Unicode ↻）
- インライン編集の UX（編集モードへの切り替えトリガー — 行クリックかボタンか）
