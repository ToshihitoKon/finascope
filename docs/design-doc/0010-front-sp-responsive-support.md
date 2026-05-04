# 0010 SP 対応（レスポンシブ）

> **scope**: front | **date**: 2026-05-04 | **issue**: #32

## 概要

スマートフォン（SP）幅で各コンポーネントがビューポートからはみ出さないようにレスポンシブ対応を行う。あわせて、ブレイクポイントとメディアクエリの書き方を `_variables.scss` と `.claude/rules/` に集約し、初学者でも迷わず実装・拡張できる土台を整える。

## 目標

- SP 幅（360px / 678px）で全コンポーネントがはみ出さず閲覧・操作できる
- 新規レコード入力フロー（`InvoiceRecordTableForm` および関連入力 UI）が SP で快適に使える
- ブレイクポイント値が `_variables.scss` の SCSS 変数として一元管理される
- メディアクエリの書き方が `.claude/rules/front-component-structure.md` の SP セクションで規約化されている
- マジックナンバーには必ずコメントが付き、初学者が読んで意味が分かる
- Chrome DevTools のデバイスツールバーで全コンポーネントを 360px / 678px / デスクトップで目視確認し、はみ出しがゼロ

## 非目標

- 機能追加（issue #32 にて明記）
- ナビゲーション構造そのものの再設計（既存のハンバーガー方式を踏襲）
- デザインシステム（色・タイポグラフィ）の刷新
- アクセシビリティの抜本的見直し
- タブレット専用の最適化（`md` 相当の中間レイアウトは作らない。`sm` 未満を SP、それ以上をデスクトップとする 2 段階）
- E2E / Visual Regression テストの自動化（実機確認は人間が DevTools で行う）

## 設計

### ブレイクポイント方針

#### 採用する値

`front/src/lib/styles/_variables.scss` に SCSS 変数として定義する。CSS 変数化はしない（メディアクエリ条件には CSS 変数が使えないため）。

```scss
// SP（スマートフォン）対応のブレイクポイント
// 360px: Android 一般的な最小幅 / iPhone SE 系より一回り狭い想定
// 678px: タブレット縦 / 大きめ SP の境界（768px ではなく 678px を採用、PC 1 カラム表示の最小幅）
$bp-sp-min: 360px;
$bp-sp-max: 678px;
```

> 値は issue #32 でユーザーが指定した「360px と 678px を SP とする」に従う。

#### レイアウト戦略

**デスクトップファースト**で書く。既存スタイルはデスクトップ向けの記述のままとし、SP 向けの上書きを `@media (max-width: $bp-sp-max)` で追記していく。

- 単一ブレイクポイント方式（`$bp-sp-max` 以下を SP として扱う）
- `$bp-sp-min` は「想定する最小幅」のドキュメント用変数。確認時の最小幅として使う
- モバイルファーストへは移行しない（既存資産を活かす + 初学者の認知負荷を下げる）

#### メディアクエリの統一フォーマット

`.claude/rules/front-component-structure.md` に SP セクションを追加し、以下を**唯一の書き方**として規約化する。

```scss
// SP 対応: 678px 以下で適用される
@media (max-width: $bp-sp-max) {
  .layout-foo {
    // SP 用の上書き
  }
}
```

- 必ず `max-width` を使う（`min-width` 併用や `between` 系は使わない）
- 必ず `$bp-sp-max` を使う（リテラル `678px` 直書き禁止）
- メディアクエリブロックは各 `.svelte` の `<style>` 末尾にまとめて置く

> dart-sass では `@media` 内の算術式を `#{}` で補間する必要があるが、変数を単独で使う場合は `#{}` 不要。Sidebar の既存記述 `@media (max-width: #{$px-sidebar-width + $px-main-max-width})` は算術が含まれるため `#{}` が必要なケース。

### コンポーネント別の対応方針

| コンポーネント | 優先度 | 方針 |
|---|---|---|
| `InvoiceRecordTableForm` | 最優先 | SP で快適に入力できること。テーブル列を間引く / 縦並びカード化を検討。横スクロール許容だが入力フィールドはタップしやすいサイズに |
| `NumberDateField` | 最優先 | 数値入力 UI として SP でタップ・入力しやすいフォントサイズ・余白 |
| `ExpenseDetails` | 高 | 入力フローの一部。SP 優先。日付セパレータ・テーブル幅調整 |
| `MonthSelector` | 中 | 月切替ボタンの折り返し・タップ領域確保 |
| `MainCategories` | 低 | SP では閲覧最低限。横スクロール許容、必要なら一部列を間引く |
| `MonthlyExpenses` | 低 | 同上。集計表示は折りたたみ or 閲覧最低限 |
| `CategoryDetails` | 低 | 同上 |
| `Pagination` | 中 | ボタンが折り返さずに収まる、または横スクロールせずタップできる |
| `Sidebar` | 対応済 | 既存ハンバーガーメニュー方式を維持。今回は手を入れない（あるいは新ブレイクポイントへの整理のみ） |

#### 「最低限の閲覧」の定義

非優先コンポーネントについて以下を満たせば OK とする:

- ビューポートからはみ出さない（横スクロールバーが body レベルで出ない）
- テーブル等は `overflow-x: auto` でコンポーネント単位の横スクロール許容
- 列を間引いた場合は、表示しない列の情報が他の手段でアクセス可能（PC で見る等）

#### 「あとから表示できるように」する手段

issue で言及された「非表示でも、あとから表示できるようになっていればよい」については、今回は**コンポーネント単位の折りたたみ UI（accordion / details）等の追加実装は行わない**。SP では情報密度を下げて表示するに留め、機能追加は次回以降の issue とする。

### `_variables.scss` の更新

```scss
$px-sidebar-width: 160px;
$px-main-max-width: 1200px;

// SP（スマートフォン）対応のブレイクポイント
// 360px: 想定する SP 最小幅（Android 一般的な最小幅）
// 678px: SP / デスクトップの境界。これ以下が SP レイアウト
$bp-sp-min: 360px;
$bp-sp-max: 678px;
```

### `.claude/rules/front-component-structure.md` の更新

末尾に以下のセクションを追加する。

```markdown
## SP（スマートフォン）対応

### ブレイクポイント

`src/lib/styles/_variables.scss` に SP 用のブレイクポイントが定義されている。

- `$bp-sp-min: 360px` — 想定する SP 最小幅（コンポーネント設計時の参照用）
- `$bp-sp-max: 678px` — SP / デスクトップの境界。これ以下が SP レイアウト

### メディアクエリの書き方（統一）

デスクトップファーストで記述する。SP 用の上書きは以下の唯一のフォーマットで書く。

\`\`\`scss
@media (max-width: $bp-sp-max) {
  .layout-foo {
    // SP 用の上書き
  }
}
\`\`\`

- `max-width` を使う（`min-width` 併用、`between` 系は使わない）
- 値は必ず `$bp-sp-max` を参照する（`678px` 直書き禁止）
- ブロックは `<style>` 末尾にまとめて置く

### 検証

Chrome DevTools のデバイスツールバーで以下を目視確認する。

- 360px / 678px / デスクトップ幅でビューポートからはみ出さない
- 入力フォームがタップしやすい（最低 44px のタップ領域）
- テーブルは `overflow-x: auto` でコンポーネント単位スクロール

### 付記: マジックナンバーの扱い

CSS の値（`px`, `rem`, `%` など）にマジックナンバーを使う場合、なぜその値かをコメントで残す。
\`\`\`scss
.layout-foo {
  padding: 12px 8px; // 12px = タップ領域確保のため最低限、8px = 横詰め
}
\`\`\`
```

## 変更ファイル一覧

実装時に変更が必要なファイル。AI が実装に取り掛かれるよう具体的に書く。

### 設定・規約

- `front/src/lib/styles/_variables.scss` — `$bp-sp-min`, `$bp-sp-max` を追加。コメント併記
- `.claude/rules/front-component-structure.md` — 「SP（スマートフォン）対応」セクションを末尾に追加

### コンポーネント（SP 用 `@media` ブロック追加）

- `front/src/lib/components/InvoiceRecordTableForm.svelte` — SP で入力しやすいレイアウト。テーブル横スクロール or カード化、入力フィールドのフォント・余白調整
- `front/src/lib/components/NumberDateField.svelte` — SP でタップしやすい入力エリア・フォントサイズ
- `front/src/lib/components/ExpenseDetails.svelte` — SP でテーブルがはみ出さない、日付セパレータ調整
- `front/src/lib/components/MonthSelector.svelte` — SP で月切替ボタンが折り返さず収まる
- `front/src/lib/components/Pagination.svelte` — SP でページネーションボタンが収まる
- `front/src/lib/components/MainCategories.svelte` — SP で横スクロール許容、必要なら列間引き
- `front/src/lib/components/MonthlyExpenses.svelte` — 同上
- `front/src/lib/components/CategoryDetails.svelte` — 同上

### ページ

- `front/src/routes/+page.svelte` — ページレベルのレイアウトに SP の余白・配置調整があれば追加
- `front/src/routes/+layout.svelte` — 必要に応じて

### 触らないファイル

- `front/src/lib/components/Sidebar.svelte` — 既存のハンバーガー化が機能しているため、原則手を入れない。ただし `_variables.scss` の新変数を使うほうが綺麗なら整理してもよい（任意）

## 実装ステップ

依存関係を考慮した順序。各ステップは独立したコミット単位として書ける粒度。

1. **規約とブレイクポイント変数の整備**
   - `front/src/lib/styles/_variables.scss` に `$bp-sp-min`, `$bp-sp-max` を追加（コメント付き）
   - `.claude/rules/front-component-structure.md` に SP セクションを追加
   - `pnpm svelte-check && pnpm lint:style` で既存が壊れていないことを確認

2. **入力系コンポーネントの SP 対応（最優先）**
   - `NumberDateField.svelte`
   - `InvoiceRecordTableForm.svelte`
   - `ExpenseDetails.svelte`
   - 各ファイルの `<style>` 末尾に統一フォーマットの `@media (max-width: $bp-sp-max)` ブロックを追加
   - DevTools で 360px / 678px / デスクトップを目視確認

3. **ナビゲーション系コンポーネントの SP 対応**
   - `MonthSelector.svelte`
   - `Pagination.svelte`

4. **閲覧系コンポーネントの SP 対応（最低限）**
   - `MainCategories.svelte`
   - `MonthlyExpenses.svelte`
   - `CategoryDetails.svelte`
   - 横スクロール許容 / 列間引きの方針で対応

5. **ページレベルの最終調整**
   - `+page.svelte`, `+layout.svelte` のレイアウト・余白を SP 向けに調整
   - 全画面を DevTools で再確認

6. **検証とコミット**
   - `pnpm svelte-check`, `pnpm eslint`, `pnpm lint:style` の 3 つすべてパス
   - Design Doc 末尾に実装サマリーを追記
   - コミット → ブランチ push → PR 作成

## 代替案

### モバイルファースト
**不採用**。既存資産がデスクトップファーストで書かれており、書き換えコストとレビューコストが大きい。初学者が触る前提なら認知負荷の低いデスクトップファーストの方が安全。

### Tailwind 風 `sm/md/lg/xl` 多段ブレイクポイント
**不採用**。今回はタブレット最適化を非目標としており、2 段階で十分。ブレイクポイントが増えると初学者が混乱する。将来必要になれば `$bp-md`, `$bp-lg` を追加すれば拡張可能。

### CSS 変数でブレイクポイントを管理
**不採用**。CSS 変数（`var(--bp-sp-max)`）はメディアクエリ条件式で評価されない（`@media (max-width: var(...))` は動かない）。SCSS 変数で扱うのが標準。

### SCSS mixin（`@mixin sp { @media ... }`）でラップ
**今回は採用しない**。`@include sp { ... }` の方がタイプ量は少ないが、初学者が「mixin は何？」と引っかかる懸念がある。生の `@media (max-width: $bp-sp-max) { ... }` の方が標準的な CSS 知識でそのまま読める。次の SP 対応 issue で要望が出れば導入を検討する。

### 列間引きを Svelte の `{#if}` で実装
列の表示/非表示は CSS の `display: none` ではなく `{#if !isSp}` で DOM ごと出し分ける案。今回は **CSS の `display: none` を優先**する。理由は (a) JS で画面幅を監視するロジックが必要になり初学者には複雑、(b) スタイル層で完結する方が変更箇所が局所化される、(c) アクセシビリティで重大な問題が出る場面はテーブル列程度なら少ない。必要なら次回以降に検討。

## 未解決事項

- **`InvoiceRecordTableForm` の SP レイアウトの最終形**: 横スクロールで通すか、入力 UI をカード型に組み替えるか。実装着手時に DevTools で実際に並べてみて判断する。判断は実装者に委ねる
- **テーブルの列間引き基準**: どの列を SP で隠すかは各テーブルで個別判断。原則「主キー的な列（日付・金額）は残す、補助列（メモ・カテゴリ詳細）は候補」
- **タップ領域 44px の厳格適用**: 既存ボタンで 44px を満たさないものがある場合、SP のみ拡大するか全体で揃えるか。今回は **SP のみ拡大** で進めるが、デザイン整合に違和感が出たら相談
