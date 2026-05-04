---
paths:
  - "front/src/**/*.svelte"
  - "front/src/**/*.ts"
  - "front/src/**/*.scss"
  - "front/src/**/*.css"
---

# フロントエンド実装ガイドライン（ファイル構成・スタイリング方針）

CSS クラス命名規則は別ファイル `.claude/rules/front-style-naming.md` を参照すること。

## ファイル構成の役割分担

- UI 要素（テーブル、フォーム、サイドバーなど）は `src/lib/components/` に実装する
- `src/routes/+page.svelte` にはコンポーネントのインポート・配置、ページ固有の状態管理・TypeScript、ページレベルのレイアウト・スタイルを記述する
- `src/lib/components/index.ts` でコンポーネントをまとめてエクスポートする

## スタイリング方針

### グローバル変数

- グローバル CSS 変数とグローバル SCSS 変数は `src/app.scss` に定義する
- CSS/SCSS 変数命名規則: `--{type}-{role}` 形式（CSS変数）、`${type}-{role}`（SCSS変数）
  - タイプ接頭辞: `color`, `px`, `rem`, `font` など
  - 例: `--color-primary`, `--px-sidebar-width`, `--px-main-max-width`

### コンポーネントスタイル内での参照

- コンポーネントスタイルでは `var(--variable-name)` でグローバル CSS 変数を参照する
- メディアクエリのブレークポイント計算には SCSS 変数を使用する
  - 例: `@media (max-width: #{$px-sidebar-width + $px-main-max-width})`
- dart-sass では `@media` 内の算術式を `#{}` で補間する必要がある

## 注意事項

- 未使用変数・引数は `_` プレフィックスで無視できる（例: `_error`, `_req`）
- Svelte 5 のリアクティブ Map は `SvelteMap`（`svelte/reactivity`）を使う。`$state` でラップすると `svelte/no-unnecessary-state-wrap` エラーになるため不要
- `SvelteMap` を変数ごと再代入するのではなく `.clear()` + `.set()` で変更する（再代入すると `$state` なしでは reactivity が失われる）
