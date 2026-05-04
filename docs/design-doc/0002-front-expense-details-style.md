# 0002 expense-details-style

> **scope**: front | **status**: Done | **date**: 2026-03-09

## 概要

`ExpenseDetails` コンポーネントのテーブルに横スクロールを追加し、新規レコード作成行のフォーム要素をスタイリッシュに整える。

## 背景・課題

- テーブルの列数が多いため、ウィンドウ幅が狭いと折り返しが発生して表示が崩れる
- 新規レコード作成行の `<input>` / `<select>` がブラウザデフォルトのスタイルのままで、既存のテーブルデザインと統一感がない

## 目標

- [ ] テーブルが横スクロール可能になり、折り返しが発生しなくなる
- [ ] 新規レコード作成行のフォーム要素が既存デザインと統一感のある見た目になる

## 非目標

- スマートフォン向けレスポンシブ対応は行わない

## 設計

### フロントエンド設計

#### 横スクロール対応

テーブルを `overflow-x: auto` のラッパーで囲み、テーブル自体には `white-space: nowrap` と `min-width` を設定して折り返しを防ぐ。

```
<div class="layout-table-scroll">   ← 新規追加
  <table class="style-table">
    ...
  </table>
</div>
```

- `.layout-table-scroll`: `overflow-x: auto; width: 100%;`
- `.style-table`: `min-width` を適切な値（例: 800px）に設定する
- テーブルセル・ヘッダーに `white-space: nowrap` を付与して折り返しを防ぐ

#### フォームのスタイリング

現在も `.style-table input[type='text']`, `.style-table input[type='number']`, `.style-table select` にスタイルは当たっているが、以下の観点で整える：

- フォーカス時のアウトライン: ブラウザデフォルトではなく `outline` / `box-shadow` をプロジェクトのカラー変数に合わせる（`--color-primary` を利用）
- フォントサイズ: テーブルセルの本文と揃える
- 高さ・縦位置: セルの高さ (`height: 36px`) に合わせて自然な見た目にする
- `<select>` の見た目: `-webkit-appearance: none` などでブラウザ差異を吸収し、統一感を出す
- プレースホルダーの色: 薄いグレー（例: `#aaa`）で補助テキストとして視認しやすくする

#### 変更ファイル一覧

- `front/src/lib/components/ExpenseDetails.svelte` — テーブルラッパー追加、フォームスタイルの改善、`white-space: nowrap` の追加
- `front/src/app.scss`（必要に応じて） — グローバル変数の追加が必要な場合のみ

## 実装ステップ

1. `ExpenseDetails.svelte` の `<div class="layout-container">` の内側で `<table>` を `<div class="layout-table-scroll">` で囲み、`.layout-table-scroll` に `overflow-x: auto` を設定する
2. `.style-table` に `min-width` を設定し、`th` / `td` に `white-space: nowrap` を追加してテーブルの折り返しを防ぐ
3. `.style-table input`, `.style-table select` のスタイルを整える（フォーカス、フォントサイズ、高さ、`<select>` のカスタマイズ、プレースホルダー色）

## 代替案

- **テーブルを `position: sticky` カラム対応にする案**: 実装コストが高く今回の課題（折り返し）の解決に不要なため不採用
- **`table-layout: fixed` で幅を固定する案**: 各列の最適幅管理が煩雑になるため不採用

## 未解決事項

- [x] テーブルの `min-width` の具体的な値（実装時に目視で調整） → `800px`
- [x] フォーカス時のカラー（`--color-primary` をそのまま使うか、薄くするか） → アンダーラインのみ `--color-primary`、背景は `rgba(255,255,255,0.6)`

## 実装サマリ

### ExpenseDetails.svelte

**レイアウト構造の変更:**
- `layout-container` × 2 を廃止し、`layout-details` で全体を囲む構造に変更
- `layout-details`: `max-width: 1024px; margin: 0 auto; padding: 0 16px` で中央揃え＋左右余白
- `layout-table-scroll` を `layout-details` 内に移動し、`scrollbar-width: none` / `::-webkit-scrollbar { display: none }` でスクロールバー非表示

**テーブルの折り返し防止:**
- `.style-table`: `min-width: 800px` 追加
- `th` / `td`: `white-space: nowrap; vertical-align: middle; text-align: center` 追加
- 日付列（`td:nth-child(2)`）と `.layout-title` は `text-align: left` で左揃え

**列幅の最小値設定:**
- `.layout-money`: `min-width: 100px`
- `.layout-category`: `min-width: 130px`
- `.layout-payment-method`: `min-width: 170px`
- `.layout-title`: `min-width: 150px; max-width: 300px; white-space: normal; word-break: break-all`（用途列のみ折り返し有効）

**フォーム要素のスタイリング（ボーダーなしモダンスタイル）:**
- `border: none; border-bottom: 1px solid transparent; background-color: transparent` でフラットに
- フォーカス時: `border-bottom-color: var(--color-primary); background-color: rgba(255,255,255,0.6)`
- `input[type='number']` のスピナー非表示（`appearance: textfield` / `::-webkit-inner-spin-button` 除去）
- `select`: `appearance: none` でカスタム ▼ アイコン（SVG）に変更

### DateField.svelte

- `locale = 'ja-JP'` をデフォルト値として追加し `DateField.Root` に渡す（日付順序を yyyy/mm/dd に）
- `literal` セグメント（区切り文字）を `'-'` で上書きして `yyyy-mm-dd` 表示に（locale は変更しない）
- `layout-date-input` ラッパー div を追加し、`input`/`select` と同じフラットスタイルを適用
- `font-size: inherit; font-family: inherit` を wrapper と `:global([data-segment])` に設定してフォント統一
