# 0001 明細一覧機能実装

> **scope**: front | **status**: Done | **date**: 2026-03-09

## 概要

`ExpenseDetails` コンポーネントを動作する状態まで実装する。
テーブル表示・新規レコード作成フォームの UI が揃っており、これらを正常に動作させる。

## 背景・課題

`ExpenseDetails.svelte` はテーブル表示・新規入力行・`handleCreate` が実装済みで、コンパイルも通っている。
ただし `svelte-sonner` の `<Toaster />` コンポーネントがレイアウトに配置されていないため、
`toast.success()` / `toast.error()` の通知が画面に表示されない。

## 目標

- [x] 明細一覧テーブルにレコードが表示される（実装済み・確認のみ）
- [x] 新規入力行から「追加」ボタンで `createRecord` が呼ばれ、値が送信される（実装済み・確認のみ）
- [x] 作成後に一覧が再取得・再描画される（`onRefresh` 経由、実装済み・確認のみ）
- [x] `toast.success()` / `toast.error()` の通知が画面に表示される

## 非目標

- UI の詳細なスタイル調整
- スマートフォン対応
- mock データの変更・拡充
- レコードの編集・削除機能

## 設計

### 現状の把握

- `front/src/lib/api/v1/mock/index.ts` に mock 実装が存在し、必要な関数はすべて揃っている
- `ExpenseDetails.svelte` の `handleCreate` は実装済み。バリデーション（日付・金額・用途）・API 呼び出し・フォームリセット・`onRefresh` 呼び出しが含まれる
- `+page.svelte` は `records` と `onRefresh={loadData}` を `ExpenseDetails` に渡している

### Toast 表示の修正

`svelte-sonner` は `<Toaster />` コンポーネントを DOM に配置しないと通知が表示されない。
`+layout.svelte` に `<Toaster />` を追加する。

### `ExpenseDetails.svelte` の確認・修正ポイント

- `onMount` でカテゴリ・支払方法を取得し、select の初期値を設定している（実装済み）
- `newTypeId` の初期値が `0` になっているが `RecordTypes` の先頭 id も `0` なので問題なし
- `newStateId` の初期値が `0` だが `States` 先頭 id も `0` なので問題なし
- フォームリセット時に `newCategoryId` / `newPaymentMethodId` がカテゴリ一覧に依存するため、`onMount` と同じロジックで設定している（実装済み）

## 変更ファイル一覧

- `front/src/routes/+layout.svelte` — `<Toaster />` コンポーネントを追加する

## 実装ステップ

1. `front/src/routes/+layout.svelte` に `svelte-sonner` の `<Toaster />` を追加する
   - `<script>` に `import { Toaster } from 'svelte-sonner'` を追加
   - テンプレートの適切な位置（`<main>` の外側など）に `<Toaster />` を配置
2. ブラウザで動作確認する
   - 新規入力行に日付・金額・用途を入力して「追加」を押すと `toast.success('レコードを作成しました')` が表示されること
   - バリデーション失敗時に `toast.error(...)` が表示されること

## 未解決事項

- [ ] `api.ts` の実際の API に切り替える時期・方法は別途検討
