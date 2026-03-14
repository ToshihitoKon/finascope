# 0004 カテゴリ編集ウィジェット

> **scope**: front | **date**: 2026-03-14

## 概要

トップページ下部にカテゴリの一覧表示・新規追加・編集ができるウィジェットを追加する。
`ExpenseDetails` と同様のテーブルスタイルで、インライン入力フォームによる追加・編集操作を提供する。

## 目標

- カテゴリ一覧をテーブルで表示できる
- 新規カテゴリをインラインフォームで追加できる
- 既存カテゴリの `label` をインライン編集できる
- トップページ（`/`）の下部にウィジェットが配置されて完動する

## 非目標

- カテゴリの削除（API 側の改修が必要なため今回は対象外）
- レイアウト・デザインの細かい調整

## 設計

### 使用する API

既存の API をそのまま利用する。追加・変更は不要。

| 関数 | 説明 |
|------|------|
| `fetchCategories()` | カテゴリ一覧取得 |
| `createCategory(req)` | 新規カテゴリ作成 |
| `updateCategory(req)` | カテゴリ編集 |

**CreateCategoryRequest / Response**, **UpdateCategoryRequest / Response** は `front/src/lib/api/v1/types.d.ts` に定義済み。
feature flag による mock/real 切り替えは既存の仕組みをそのまま使う（`front/src/lib/api/v1/index.ts` 経由で呼び出す）。

### フロントエンド設計

#### コンポーネント

新規コンポーネント `CategoryDetails.svelte` を `front/src/lib/components/` に追加する。

**Props:**
```typescript
interface Props {
  // なし（内部で fetchCategories を呼び出す）
}
```

**内部状態:**
```typescript
let categories = $state<Category[]>([]);
let editingId = $state<string | null>(null);   // 編集中カテゴリの id
let editingLabel = $state<string>('');          // 編集中の label バッファ
let newLabel = $state<string>('');             // 新規追加フォームの label
```

**UI 構造:**

- `<h2>カテゴリ</h2>`
- スクロール可能なテーブル（`ExpenseDetails` 準拠のスタイル）
  - カラム: `label` | 操作ボタン
  - 各行: 通常表示時は `label` テキスト + 「編集」ボタン
  - 編集中行: `label` の `<input type="text">` + 「保存」「キャンセル」ボタン
  - 末尾の新規追加行: `<input type="text" placeholder="カテゴリ名">` + 「追加」ボタン

#### トップページへの統合

`front/src/routes/+page.svelte` に `CategoryDetails` を追加し、`ExpenseDetails` の下に配置する。
`CategoryDetails` は内部でデータ取得を完結させるため、`+page.svelte` での状態追加は不要。

## 変更ファイル一覧

- `front/src/lib/components/CategoryDetails.svelte` — 新規作成：カテゴリ一覧・追加・編集ウィジェット
- `front/src/lib/components/index.ts` — `CategoryDetails` をエクスポートに追加
- `front/src/routes/+page.svelte` — `CategoryDetails` をインポートし、divider + ウィジェットをページ末尾に追加

## 実装ステップ

1. `CategoryDetails.svelte` を新規作成する
   - `onMount` で `fetchCategories()` を呼び出してカテゴリ一覧を取得
   - テーブル表示・インライン編集（`editingId` で編集行を管理）・新規追加フォームを実装
   - `createCategory` / `updateCategory` 呼び出し後に一覧をリロードする
   - `ExpenseDetails` 準拠のスタイル（`style-table`, `style-button` など）を使用する
2. `front/src/lib/components/index.ts` に `CategoryDetails` をエクスポート追加
3. `front/src/routes/+page.svelte` にdivider と `<CategoryDetails />` を追加

## 代替案

- **モーダルでの追加・編集**: `ExpenseDetails` と UI 統一感を保つためインライン編集を採用
- **ページを分ける（`/settings` など）**: トップページからすぐ操作できる利便性を優先してトップページ内配置を採用

## 未解決事項

- カテゴリ削除時のレコード紐付け処理は API 側の改修後に別 Design Doc で対応予定
