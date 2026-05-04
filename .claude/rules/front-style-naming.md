---
paths:
  - "front/src/**/*.svelte"
  - "front/src/**/*.scss"
  - "front/src/**/*.css"
---

# フロントエンド CSS クラス命名規則

`front/src/` 配下の `.svelte` / `.scss` / `.css` ファイルにおける CSS クラス名のルール。

## プレフィックスの種類

すべての CSS クラス名は以下のいずれかのプレフィックスで始める。

| プレフィックス | 用途 | 例 |
|---|---|---|
| `layout-` | DOM の配置・レイアウトに関するスタイル（`display`, `flex`, `position`, `margin`, `padding`, `text-align` など） | `layout-container`, `layout-summary`, `layout-money` |
| `style-` | 色・フォント・ボーダーなど見た目に関するスタイル（`color`, `background`, `border`, `font-size` など）。単一プロパティの汎用的な見た目もここに含める | `style-table`, `style-button`, `style-text-muted`, `style-date-sep` |
| `is-` | 状態を表すクラス（boolean 的な ON/OFF の切り替え） | `is-open`, `is-invalid` |
| `has-` | 子要素の有無や所有関係を表す状態クラス | `has-error`, `has-children` |

## 両方の性質を持つ要素

DOM 配置と見た目の両方を持つ要素には `layout-foo style-foo` のように両クラスを付与する。各 Svelte ファイルの `<style>` ブロック内で `layout-*` と `style-*` を分けて記述する。

例:
```svelte
<aside class="layout-sidebar style-sidebar">...</aside>

<style>
  .layout-sidebar {
    display: flex;
    flex-direction: column;
  }
  .style-sidebar {
    background-color: var(--color-sidebar-bg);
  }
</style>
```

## 状態クラス

状態を切り替える場合は `class:is-foo={condition}` のように Svelte の `class:` ディレクティブを使う。

例:
```svelte
<div class="layout-date-field" class:is-invalid={isInvalid}>...</div>

<style>
  .layout-date-field.is-invalid {
    border-bottom-color: #dc3545;
  }
</style>
```

JS 側の状態変数名も `isInvalid`, `isOpen` のように `is` プレフィックスで揃える。

## コンポーネント内ローカルクラスの例外

Svelte の scoped CSS によりコンポーネント内に閉じる小さな構造的子要素については、自明であればプレフィックスなしの短い名前を許容する。

許容例:
- `NumberDateField.svelte` の `.input-day`, `.input-month`, `.input-year`, `.sep` のような、コンポーネントの構造を表す子要素

判断基準:
- そのコンポーネント内でのみ使われ、他からは参照されない
- 役割が名前から自明である（`.x`, `.foo` のような曖昧な名前は不可）
- 状態クラスは必ず `is-` / `has-` を使う（短縮しない）

迷ったら `layout-*` / `style-*` を付ける方を選ぶ。例外は最小限に留める。

## 検出ハーネス

CSS 定義時の規約違反は Stylelint で自動検出される。

```bash
cd front
pnpm lint:style
```

`selector-class-pattern` ルールで上記プレフィックスを正規表現で強制する。コンポーネント内ローカルクラスの例外は `.stylelintrc.json` の設定で扱われる。

## リネーム例（参考）

過去のリファクタで以下のリネームを行った（issue #30, ddoc 0009）:

| Before | After | 理由 |
|---|---|---|
| `.invalid` (`class:invalid`) | `.is-invalid` (`class:is-invalid`) | 状態クラス規約 |
| `.text-muted` | `.style-text-muted` | プレフィックス付与（見た目） |
| `.unregistered-row` | `.style-unregistered-row` | プレフィックス付与（見た目） |
| `.date-sep` | `.style-date-sep` | プレフィックス付与（見た目） |
