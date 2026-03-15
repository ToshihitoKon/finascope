# 0006 front-modernize-ui-style

> **scope**: front | **date**: 2026-03-15

## 概要

Tailwind CSS を使用せず、CLAUDE.md の CSS 設計規則に則り、フロントエンド UI をモダンなカードデザインに刷新する。
ページ背景をグレーにして各セクションを白いカードとして表示し、サイドバーもライトグレー系に統一する。

## 目標

- 画面全体の背景色をグレーに変更し、各セクション（MonthlyExpenses・ExpenseDetails・CategoryDetails）を白いカードとして立体的に表示する
- `app.scss` にモダン UI 用のグローバル CSS 変数（`--color-page-bg`, `--color-card-bg`, `--color-border`, `--color-text-muted`, `--shadow-md` など）を追加する
- `layout-devider` / `style-devider` 要素を削除し、カード間の `gap` で視覚的区切りを表現する
- テーブルのゼブラ柄（`nth-of-type(even/odd)` の背景色）を削除し、行の区切りに `border-bottom` を使用する
- サイドバーをダーク背景（`#2c2c2c`）からページ背景と統一したライトグレー系に変更する
- `MonthSelector.svelte` のセレクトボックス・ボタンのスタイルをカードデザインのトーンに合わせる
- `InvoiceRecordTableForm.svelte` のテーブルスタイルも同様に更新する
- `layout-` / `style-` プレフィックスルールに基づくクラスの分離を厳格に適用する

## 非目標

- 既存ロジックの改修や新機能の追加
- API およびデータベースの変更
- Tailwind CSS の導入
- レイアウト構造（サイドバーの位置・幅・レスポンシブ挙動）の変更

## 設計

### フロントエンド設計

#### グローバル CSS 変数（`app.scss`）

以下の変数を `:root` に追加・変更する：

| 変数名 | 値 | 用途 |
|--------|-----|------|
| `--color-page-bg` | `#f0f2f5` | ページ全体の背景色（グレーに変更） |
| `--color-card-bg` | `#ffffff` | カード背景色 |
| `--color-border` | `#e2e4e9` | 汎用ボーダー色 |
| `--color-text-muted` | `#6b7280` | 補助テキスト色 |
| `--shadow-md` | `0 2px 8px rgba(0,0,0,0.08)` | カードの影 |
| `--color-sidebar-bg` | `#f0f2f5` | サイドバー背景（ページ背景と統一） |
| `--color-sidebar-text` | `#4b5563` | サイドバーテキスト（ライトグレー系） |

#### カードデザインの共通スタイル

各コンポーネントのセクション要素に以下のスタイルを適用する（`style-card` クラスとして定義）：

```css
.style-card {
    background-color: var(--color-card-bg);
    border: 1px solid var(--color-border);
    border-radius: 12px;
    box-shadow: var(--shadow-md);
}
```

#### テーブル行の区切り

ゼブラ柄を削除し、各 `td` / `th` に `border-bottom` を適用：

```css
.style-table td, .style-table th {
    border-bottom: 1px solid var(--color-border);
}
```

#### セクション間の区切り

`+page.svelte` の `layout-devider` / `style-devider` 要素を削除し、コンテンツラッパーに `gap: 16px` を設定する。

#### サイドバー（`Sidebar.svelte`）

- `--color-sidebar-bg` を `#f0f2f5`（ページ背景と同色）に変更
- `--color-sidebar-text` を `#4b5563` に変更
- `border-right: 1px solid var(--color-border)` を追加して境界を表現
- ホバー時のテキスト色を `#111827`（ほぼ黒）に変更

#### `style-new-row` / `unregistered-row`（特別な行）

ゼブラ柄削除後も視覚的に区別する。薄いブルー（`#f0f4ff`）から `var(--color-primary-bg)` ベースのスタイルに変更する。

## 変更ファイル一覧

- `front/src/app.scss` — グローバル CSS 変数の追加・更新（`--color-page-bg` をグレーに変更、`--color-card-bg` / `--color-border` / `--color-text-muted` / `--shadow-md` を追加、`--color-sidebar-bg` / `--color-sidebar-text` を更新）
- `front/src/routes/+layout.svelte` — `layout-main` にパディング追加
- `front/src/routes/+page.svelte` — `layout-devider` / `style-devider` 要素と対応スタイルを削除、コンテンツ全体に `gap` を設定、各セクションラッパーにカード用クラスを追加
- `front/src/lib/components/MonthlyExpenses.svelte` — 既存の `border` をカードスタイルに置き換え
- `front/src/lib/components/ExpenseDetails.svelte` — カードスタイルを適用、ゼブラ柄削除・`border-bottom` による行区切り、`style-new-row` スタイル調整
- `front/src/lib/components/CategoryDetails.svelte` — カードスタイルを適用、ゼブラ柄削除・`border-bottom` による行区切り、`style-new-row` スタイル調整
- `front/src/lib/components/MonthSelector.svelte` — `style-select` のボーダー色を `--color-border` に変更、スタイルをカードデザインのトーンに調整
- `front/src/lib/components/InvoiceRecordTableForm.svelte` — ゼブラ柄削除・`border-bottom` による行区切り、`text-muted` の色を `--color-text-muted` に変更、`unregistered-row` スタイル調整
- `front/src/lib/components/Sidebar.svelte` — CSS 変数でライトグレー系に変更、`border-right` 追加、ホバー色更新

## 実装ステップ

依存関係を考慮した順序で書く。各ステップは独立したコミット単位になるとよい。

1. **`app.scss` にグローバル CSS 変数を追加・更新する**
   - `--color-page-bg` を `#f0f2f5` に変更
   - `--color-card-bg`, `--color-border`, `--color-text-muted`, `--shadow-md` を追加
   - `--color-sidebar-bg` を `#f0f2f5` に変更
   - `--color-sidebar-text` を `#4b5563` に変更

2. **`+layout.svelte` を更新する**
   - `layout-main` に適切なパディングを追加

3. **`Sidebar.svelte` をライトグレー系デザインに更新する**
   - `style-sidebar` の背景色を CSS 変数で参照
   - `style-nav-item` のテキスト色・ホバー色（`#111827`）を更新
   - `border-right: 1px solid var(--color-border)` を追加
   - `style-close-button` の色を更新

4. **`+page.svelte` を更新する**
   - `layout-devider` / `style-devider` の要素とスタイルを削除
   - コンテンツラッパーに `display: flex; flex-direction: column; gap: 16px; padding: 16px;` を追加
   - 各セクションラッパーにカード用クラスを追加

5. **`MonthlyExpenses.svelte` をカード化する**
   - 既存の `border: 2px solid var(--color-primary)` をカードスタイル（`background-color: var(--color-card-bg)`, `border: 1px solid var(--color-border)`, `box-shadow: var(--shadow-md)`）に置き換え

6. **`ExpenseDetails.svelte` を更新する**
   - ゼブラ柄スタイル（`nth-of-type(even)` の背景色）を削除
   - `th` / `td` に `border-bottom: 1px solid var(--color-border)` を追加
   - `style-new-row` の背景色を `var(--color-primary-bg)` ベースに変更
   - コンポーネント外側にカードスタイルを適用（`layout-details` に `style-card` を追加 or `+page.svelte` 側で適用）

7. **`CategoryDetails.svelte` を更新する**
   - ゼブラ柄スタイル（`nth-of-type(even)` の背景色）を削除
   - `th` / `td` に `border-bottom: 1px solid var(--color-border)` を追加
   - `style-new-row` の背景色を `var(--color-primary-bg)` ベースに変更
   - コンポーネント外側にカードスタイルを適用

8. **`MonthSelector.svelte` を更新する**
   - `style-select` のボーダー色を `var(--color-border)` に変更
   - スタイルをカードデザインのトーンに合わせて調整

9. **`InvoiceRecordTableForm.svelte` を更新する**
   - ゼブラ柄スタイル（`nth-of-type(odd)` の背景色）を削除
   - `th` / `td` に `border-bottom: 1px solid var(--color-border)` を追加
   - `text-muted` の `color: #999` を `color: var(--color-text-muted)` に変更
   - `unregistered-row` の背景色を `var(--color-primary-bg)` ベースに変更（未登録行の区別を維持）

## 代替案

### テーブル行の区切りにホバーハイライトのみを使う案

削除後の行区切りとしてホバー時の背景色変化のみで対応する案も検討したが、静止状態での視認性確保のため `border-bottom` を採用した。

### サイドバーをホワイト（`#ffffff`）にする案

サイドバーを白カードと同色にする案も検討したが、メインコンテンツとサイドバーの区別がつきにくくなるため、ページ背景色（グレー）と統一してボーダーで境界を表現する方針にした。

## 未解決事項

なし

---

## 実装サマリー

> **実装日**: 2026-03-15

### 変更ファイル

- `front/src/app.scss` — グローバル CSS 変数を追加・更新（`--color-page-bg` をグレー化、`--color-card-bg` / `--color-border` / `--color-text-muted` / `--shadow-md` / `--color-table-header-bg` / `--color-text-heading` を追加、サイドバー変数をライトグレー系に変更）
- `front/src/routes/+layout.svelte` — `layout-main` のパディングを削除（ページ側に委譲）
- `front/src/routes/+page.svelte` — `layout-devider` / `style-devider` を削除、`style-card` / `layout-page` でカードレイアウトを構成、MonthSelector を ExpenseDetails の下に移動、各セクションを左寄せ、CategoryDetails に `layout-section-narrow`（`max-width: 680px`）を適用
- `front/src/lib/components/MonthlyExpenses.svelte` — `border` をカードスタイルに置き換え
- `front/src/lib/components/ExpenseDetails.svelte` — ゼブラ柄削除・`border-bottom` 追加、テーブルヘッダーをグレー文字＋薄グレー背景に、ボタンをアウトラインスタイルに、カードタイトルのスタイル追加
- `front/src/lib/components/CategoryDetails.svelte` — 同上に加え、`layout-actions` を右寄せに変更
- `front/src/lib/components/MonthSelector.svelte` — `style-select` のボーダーを `--color-border` に変更
- `front/src/lib/components/InvoiceRecordTableForm.svelte` — ゼブラ柄削除・`border-bottom` 追加、テーブルヘッダースタイル統一、ボタンをアウトラインスタイルに、`text-muted` を CSS 変数に変更
- `front/src/lib/components/Sidebar.svelte` — ライトグレー系に変更、`border-right` 追加、ホバー色更新

### 実装内容

ddoc の設計通りに概ね進んだ。以下の点で設計時から変更・追加があった：

- **パディング構造の再設計**: 当初は `layout-main` / `layout-details` 両方にパディングを設定していたが、二重になる問題が発生。`layout-main` のパディングを削除し、`layout-page`（ページ外縁）と `style-card`（カード内）に分離して管理する構造に整理した。
- **`layout-section` の `width: 100%` 問題**: flex 子要素に `width: 100%` を指定すると `layout-page` の `padding` 分がはみ出す問題が発生。`width: 100%` を削除し `min-width: 0` のみに変更した。
- **CSS 変数の追加**: ddoc に記載のなかった `--color-table-header-bg`（`#f9fafb`）と `--color-text-heading`（`#374151`）を追加。テーブルヘッダーのピンク背景廃止とカードタイトルのスタイル統一に使用。
- **レビュー対応で追加した変更**: 実装後のレビューを経て以下を追加実施した：
  - テーブルヘッダーのピンク背景（`--color-primary-bg`）を薄グレー（`#f9fafb`）に変更
  - シャドウを `0 1px 3px rgba(0,0,0,0.06)` に引き締め
  - ボタンをアウトラインスタイル（白背景・ピンク枠・ピンク文字、ホバー時塗りつぶし）に変更
  - カードタイトルの文字サイズ・太さ・色を調整（最終的に `1rem` / `font-weight: 700` / `#1f2937`）
  - CategoryDetails カードを `max-width: 680px` で左寄せ、MonthSelector を ExpenseDetails の下に移動

### 確認・検証

`pnpm svelte-check` でエラー・警告ともに 0 件を確認。

### 気づき・備考

- カードスタイル（`style-card`）は `+page.svelte` 側で定義・適用し、コンポーネント内の `layout-details` はコンテンツ管理のみに専念させた。コンポーネント境界でカードを制御する構造は再利用性が高い。
- `--color-primary-bg` は今後テーブルヘッダーや入力行の背景としては使わず、ピンクアクセントが必要な箇所に限定するとよい。テーブル系の背景は `--color-table-header-bg` で統一するのが望ましい。
- `layout-section-narrow` のような幅制限クラスをページ側で管理するパターンは、コンポーネントを汎用的に保ちつつページごとのレイアウト調整がしやすく有効。
