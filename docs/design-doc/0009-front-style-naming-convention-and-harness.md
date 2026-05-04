# 0009 style 命名規則の統一とハーネスの作成

> **scope**: front, docs | **date**: 2026-05-04

## 概要

フロントエンドの CSS クラス命名規則を整理・拡張し、既存コードの逸脱箇所を規約に沿ってリネームする。さらに、AI Agent への事前指示として `.claude/rules/` のパススコープルール、事後検出として Stylelint を導入する二重ハーネスを構築する。

機能変更は伴わない純粋なリファクタリングおよび開発基盤の整備。

## 目標

- 命名規約を、状態クラス・コンポーネント内ローカルクラスを含めた完全な仕様に拡張する
- `front/src/` 配下の全 Svelte コンポーネントの逸脱クラスを規約に沿ってリネームする
- フロントエンド実装ガイドラインを `.claude/rules/` に分離し、`front/` を触るときだけ AI Agent に読み込まれるようにする（CLAUDE.md のコンテキスト消費を削減）
- Stylelint で `selector-class-pattern` を強制するハーネスを導入し、`pnpm` script として実行可能にする
- 既存機能（見た目・挙動）が一切変わらない

## 非目標

- 機能を変更するリファクタリング（プロパティ追加、コンポーネント分割、ロジック改修など）
- 色・スペーシングなどデザイン値の変更
- 既存コンポーネントのプロパティインターフェース変更
- ESLint カスタムルールや独自 Node.js スクリプトによるチェック（Stylelint で十分と判断）
- CI（GitHub Actions）への組み込み（今回はローカル実行のみ。CI 化は別 issue）
- バックエンド側の規約整備（今回は `front` スコープのみ）

## 設計

### ハーネスの全体像

二重のハーネスを構築する。

| 層 | 仕組み | 効く場面 |
|---|---|---|
| 事前 | `.claude/rules/front-*.md`（パススコープルール） | AI Agent が `front/` のファイルを読み書きするとき、規約をコンテキストに自動投入 |
| 事後 | Stylelint `selector-class-pattern` | 手動編集・AI 経由問わず、CSS 定義時の規約違反を検出 |

CLAUDE.md は概要とポインタのみに留め、詳細は `.claude/rules/` に委ねる。これにより：
- CLAUDE.md は全セッションで読み込まれるが、フロントエンド固有のガイドラインは `front/` 配下を触るときだけ読み込まれる → コンテキスト節約
- ルールが大きくなっても CLAUDE.md の 200 行ガイドラインを圧迫しない

### 命名規約（拡張版）

#### プレフィックスの種類

| プレフィックス | 用途 | 例 |
|---|---|---|
| `layout-` | DOM の配置・レイアウトに関するスタイル（`display`, `flex`, `position`, `margin`, `padding`, `text-align` など） | `layout-container`, `layout-summary` |
| `style-` | 色・フォント・ボーダーなど見た目に関するスタイル（`color`, `background`, `border`, `font-size` など）。単一プロパティの汎用的な見た目もここに含める | `style-table`, `style-button`, `style-text-muted` |
| `is-` | 状態を表すクラス（boolean 的な ON/OFF の切り替え） | `is-open`, `is-invalid` |
| `has-` | 子要素の有無や所有関係を表す状態クラス | `has-error`, `has-children` |

#### コンポーネント内ローカルクラスの例外

Svelte の scoped CSS によりコンポーネント内に閉じる小さな構造的子要素については、自明であればプレフィックスなしの短い名前を許容する。

許容例:
- `NumberDateField.svelte` の `.input-day`, `.input-month`, `.input-year`, `.sep` のような、コンポーネントの構造を表す子要素

判断基準:
- そのコンポーネント内でのみ使われ、他からは参照されない
- 役割が名前から自明である（`.x`, `.foo` のような曖昧な名前は不可）
- 状態クラスは `is-` / `has-` を使う（短縮しない）

#### 両方の性質を持つ要素

`layout-foo style-foo` のように両クラスを付与する。各 Svelte ファイルの `<style>` ブロック内で `layout-*` と `style-*` を分けて記述する。

### `.claude/rules/` 構成

```
.claude/
└── rules/
    ├── front-component-structure.md   # ファイル構成・実装ガイドライン全般
    └── front-style-naming.md          # CSS クラス命名規則
```

#### `front-component-structure.md`

frontmatter:
```yaml
---
paths:
  - "front/src/**/*.svelte"
  - "front/src/**/*.ts"
  - "front/src/**/*.scss"
  - "front/src/**/*.css"
---
```

内容: 現 CLAUDE.md の「フロントエンド実装ガイドライン」のうち、ファイル構成・スタイリング方針（CSS 変数命名、SCSS 変数、メディアクエリ）を移植。

#### `front-style-naming.md`

frontmatter:
```yaml
---
paths:
  - "front/src/**/*.svelte"
  - "front/src/**/*.scss"
  - "front/src/**/*.css"
---
```

内容: 上記「命名規約（拡張版）」の全文を記載。プレフィックスの種類、ローカルクラス例外、判断基準、リネーム例まで含む。

### CLAUDE.md の更新

「### フロントエンド実装ガイドライン」セクションを大幅に縮小し、ポインタに置き換える:

```markdown
### フロントエンド実装ガイドライン

フロントエンドのファイル構成・スタイリング方針・CSS クラス命名規則は
`.claude/rules/` に分離されている。`front/` 配下のファイルを編集する際に
自動的に読み込まれる。

- `.claude/rules/front-component-structure.md` — ファイル構成、CSS/SCSS 変数規約
- `.claude/rules/front-style-naming.md` — CSS クラス命名規則（layout-/style-/is-/has-）
```

`## Lint チェック` セクションには `pnpm lint:style` を追記する。

### リネーム計画

事前調査で確認した逸脱箇所と、新規約に沿ったリネーム後の名前。

| ファイル | 現在のクラス | リネーム後 | 種別 |
|---|---|---|---|
| `ExpenseDetails.svelte` | `.org` | （実装時判断）※ | - |
| `ExpenseDetails.svelte` | `.w3` | （実装時判断）※ | - |
| `ExpenseDetails.svelte` | `.date-sep` | `style-date-sep` | style |
| `NumberDateField.svelte` | `.input-day` | `.input-day`（据え置き） | コンポーネント内ローカル |
| `NumberDateField.svelte` | `.input-month` | `.input-month`（据え置き） | コンポーネント内ローカル |
| `NumberDateField.svelte` | `.input-year` | `.input-year`（据え置き） | コンポーネント内ローカル |
| `NumberDateField.svelte` | `.sep` | `.sep`（据え置き） | コンポーネント内ローカル |
| `NumberDateField.svelte` | `.invalid`（`class:invalid`） | `.is-invalid`（`class:is-invalid`） | 状態 |
| `InvoiceRecordTableForm.svelte` | `.text-muted` | `style-text-muted` | style |
| `InvoiceRecordTableForm.svelte` | `.unregistered-row` | `style-unregistered-row` | style |
| `Sidebar.svelte` | `.is-open`（`class:is-open`） | `.is-open`（既に新規約準拠、据え置き） | 状態 |
| `app.scss` | `.layout-app`（未使用） | （削除） | - |
| `index.ts` / `DateField.svelte` | `DateField` コンポーネント全体（未使用） | （削除） | - |

※ `.org`, `.w3` は実装を確認のうえ、利用状況に応じて適切な `layout-*` / `style-*` 名にリネームするか、未使用なら削除する。

### Stylelint 設計

#### ツール選定

- **Stylelint** + `stylelint-config-standard-scss` + `postcss-html`（Svelte ファイル内の `<style>` ブロックを解析するため）
- ルール: `selector-class-pattern` で命名規則を正規表現で強制

#### 正規表現

```
^(layout|style|is|has)-[a-z][a-z0-9]*(-[a-z0-9]+)*$
```

許容するパターン:
- `layout-foo`, `layout-foo-bar`
- `style-foo`, `style-foo-bar-baz`
- `is-open`, `is-invalid`
- `has-error`

#### コンポーネント内ローカルクラスの例外処理

`.input-day` のような短い名前を許容するため、Stylelint の `selector-class-pattern` だけでは表現が難しい。以下のいずれかで対応する（実装時に検証）:

- (a) Stylelint の `disable-next-line` コメントで例外を明示する
- (b) 正規表現を緩めて、コンポーネントローカルとみなせる短いクラス名も許可する

実装時に試行し、Stylelint の挙動と運用しやすさを見て判断する。

#### 設定ファイル

- `front/.stylelintrc.json` を新規作成
- `front/package.json` に `"lint:style": "stylelint 'src/**/*.{svelte,scss,css}'"` を追加
- `pnpm install -D stylelint stylelint-config-standard-scss postcss-html` で依存追加

## 変更ファイル一覧

リネーム対象:
- `front/src/lib/components/ExpenseDetails.svelte` — `.org`, `.w3`, `.date-sep` を規約準拠にリネーム/削除
- `front/src/lib/components/NumberDateField.svelte` — `.invalid` → `.is-invalid` にリネーム（`class:` ディレクティブも更新）
- `front/src/lib/components/InvoiceRecordTableForm.svelte` — `.text-muted` → `style-text-muted`, `.unregistered-row` → `style-unregistered-row`
- `front/src/app.scss` — 未使用の `.layout-app` 定義を削除

未使用コンポーネント削除:
- `front/src/lib/components/DateField.svelte` — ファイル削除
- `front/src/lib/components/index.ts` — `DateField` のエクスポートを削除

`.claude/rules/` 整備:
- `.claude/rules/front-component-structure.md` — 新規作成（ファイル構成・スタイリング方針）
- `.claude/rules/front-style-naming.md` — 新規作成（CSS クラス命名規則）

ハーネス導入:
- `front/.stylelintrc.json` — 新規作成
- `front/package.json` — Stylelint 依存追加、`lint:style` script 追加
- `front/pnpm-lock.yaml` — 依存追加に伴い更新

ドキュメント:
- `CLAUDE.md` — 「フロントエンド実装ガイドライン」セクションを縮小しポインタに変更、Lint チェックセクションに `lint:style` を追記

## 実装ステップ

各ステップ完了後に **`pnpm svelte-check` と `pnpm eslint` を実行** し、エラーがないことを確認する。リネームは小さい単位で行う。

1. **未使用コンポーネントの削除**
   - `front/src/lib/components/DateField.svelte` を削除
   - `front/src/lib/components/index.ts` から `DateField` のエクスポートを削除
   - `pnpm svelte-check` 確認

2. **`app.scss` のクリーンアップ**
   - 未使用の `.layout-app` 定義を削除
   - `pnpm svelte-check` 確認、ブラウザで見た目確認（可能なら）

3. **`NumberDateField.svelte` の状態クラスリネーム**
   - `.invalid` → `.is-invalid` にリネーム（CSS セレクタ、`class:invalid` → `class:is-invalid` の両方）
   - `pnpm svelte-check` 確認、ブラウザで日付不正時の赤下線表示が出ることを確認

4. **`InvoiceRecordTableForm.svelte` のリネーム**
   - `.text-muted` → `style-text-muted`
   - `.unregistered-row` → `style-unregistered-row`
   - `pnpm svelte-check` 確認、ブラウザで未登録行の見た目が変わっていないことを確認

5. **`ExpenseDetails.svelte` のリネーム**
   - `.date-sep` → `style-date-sep`
   - `.org`, `.w3` は実装内容を確認のうえ、適切な `layout-*` / `style-*` 名にリネーム or 未使用なら削除
   - `pnpm svelte-check` 確認、ブラウザで支出詳細画面の見た目が変わっていないことを確認

6. **`.claude/rules/` ファイルの作成**
   - `.claude/rules/front-component-structure.md` を作成（CLAUDE.md のファイル構成・スタイリング方針セクションを移植、`paths` frontmatter 付与）
   - `.claude/rules/front-style-naming.md` を作成（拡張版命名規約全文、`paths` frontmatter 付与）

7. **CLAUDE.md の更新**
   - 「### フロントエンド実装ガイドライン」セクションを縮小し、`.claude/rules/` へのポインタに変更
   - 「## Lint チェック」セクションに `pnpm lint:style` を追記（手順 8 完了後にチェックリスト 3 つになる）

8. **Stylelint 導入と設定**（影響範囲が大きいため最後に実施）
   - 8-1. `pnpm install -D stylelint stylelint-config-standard-scss postcss-html` で依存追加
   - 8-2. `front/.stylelintrc.json` を作成（正規表現ルール）
   - 8-3. `pnpm exec stylelint 'src/**/*.{svelte,scss,css}'` を試行し、エラー件数を確認
   - 8-4. コンポーネント内ローカルクラス（`.input-day` 等）の例外処理を決定（disable コメント or 正規表現緩和）
   - 8-5. すべてのリネーム済みファイルが Stylelint をパスすることを確認
   - 8-6. `package.json` に `lint:style` script を追加
   - 8-7. 最終的に `pnpm svelte-check && pnpm eslint && pnpm lint:style` の 3 つすべてが通ることを確認

## 代替案

- **CLAUDE.md にすべての規約を記載**: 全セッションで読み込まれるためコンテキスト消費が大きく、フロントエンドを触らないセッション（バックエンド作業など）でも無駄になる。`.claude/rules/` のパススコープ機能で必要なときだけ読み込む方式を採用。
- **Stylelint のみで AI への事前指示を行わない**: Stylelint は事後検出のみのため、AI Agent が新規コード生成時に規約違反を含めて出力しがち。`.claude/rules/` で事前にコンテキストを与える方が手戻りが少ない。
- **ESLint カスタムルール / eslint-plugin-svelte で `class=""` 属性をチェック**: Svelte の `class=""` 属性に書かれたクラス名もチェックできる利点はあるが、Stylelint の `selector-class-pattern` で `<style>` 側を縛れば、未使用な命名違反クラスは Svelte の scoped CSS により無効化されるため実害が小さい。導入コストの方が大きいため採用しない。
- **独自 Node.js スクリプトでチェック**: 柔軟性は高いが Stylelint のエコシステム（IDE 連携、`disable-next-line` 等）が使えなくなる。標準ツールを優先する。
- **BEM 風の `layout-foo__bar` を導入**: 既存コードベースとの親和性が低く、移行コストが大きい。短い名前で十分判別できる現状の規約を拡張する方針を取る。
- **状態クラスを `state-*` プレフィックスに統一**: HTML/CSS の慣例である `is-*` / `has-*` の方が読み手に自然で、既に `Sidebar.svelte` で `is-open` が使われていることから、こちらを正式採用する。

## 未解決事項

- Stylelint の `selector-class-pattern` でコンポーネント内ローカルクラス（`.input-day` 等）をどう例外扱いするかは、実装時に試行して決定する（disable コメントで明示するか、正規表現を緩めるか）
- `.org`, `.w3`（`ExpenseDetails.svelte`）の本来の意図と適切なリネーム先は、実装時にコードを読み解いて判断する（HTML 出力、テーブルセルのレイアウト用クラスの可能性が高い）

---

## 実装サマリー

> **実装日**: 2026-05-04

### 変更ファイル

新規:
- `.claude/rules/front-component-structure.md` — フロントエンドのファイル構成・スタイリング方針・Svelte 5 の注意点を `paths` スコープ付きで記述
- `.claude/rules/front-style-naming.md` — CSS クラス命名規則（`layout-` / `style-` / `is-` / `has-`）とコンポーネント内ローカルクラス例外を `paths` スコープ付きで記述
- `front/.stylelintrc.json` — `selector-class-pattern` のみを有効化した最小構成

削除:
- `front/src/lib/components/DateField.svelte` — `NumberDateField` への置換後に未使用になっていた

修正:
- `CLAUDE.md` — 「フロントエンド実装ガイドライン」セクションを `.claude/rules/` へのポインタに置き換え、Lint チェック節に `pnpm lint:style` を追記
- `front/package.json` — `lint:style` script 追加、`stylelint` / `stylelint-config-standard-scss` / `postcss-html` を devDependency に追加
- `front/pnpm-lock.yaml` — 依存追加に伴い更新
- `front/src/app.scss` — 未使用の `.layout-app` 定義を削除
- `front/src/lib/components/index.ts` — `DateField` の export を削除
- `front/src/lib/components/ExpenseDetails.svelte` — `.date-sep` → `.style-date-sep` リネーム
- `front/src/lib/components/InvoiceRecordTableForm.svelte` — `.text-muted` → `.style-text-muted`、`.unregistered-row` → `.style-unregistered-row` リネーム
- `front/src/lib/components/NumberDateField.svelte` — `.invalid` → `.is-invalid` リネーム（CSS セレクタ、`class:` ディレクティブ、JS 変数 `invalid` → `isInvalid` を同時更新）、ローカルクラス（`.input-year` / `.input-month` / `.input-day` / `.sep`）に `stylelint-disable selector-class-pattern` ブロックを付与

### 実装内容

ddoc の実装ステップ 1 〜 8 を順に実施した。リネームは小さい単位で進め、各ステップ完了時に `pnpm svelte-check` と `pnpm eslint` を実行してレグレッションがないことを確認した。

主な決定:
- **未解決事項 1（Stylelint のローカルクラス例外処理）**: 案 (a) の `stylelint-disable` コメント方式を採用。例外箇所がコード上で可視化され、例外が増えた場合に気づける利点を重視した。`NumberDateField.svelte` の 4 つのローカルクラス（`.input-year`, `.input-month`, `.input-day`, `.sep`）を `disable`/`enable` ブロックで囲み、コメントで `.claude/rules/front-style-naming.md` の例外規定への参照を残した。
- **未解決事項 2（`.org`, `.w3` のリネーム）**: 事前調査時の grep が SVG `data:` URL 内の `xmlns='http://www.w3.org/2000/svg'` から `w3` と `org` を機械的に拾ってしまった誤検出と判明。実際の CSS クラスとしては存在しないため、対応不要として確定。
- **`.invalid` → `.is-invalid` リネームに伴う JS 変数名の同時更新**: ddoc には CSS セレクタと `class:` ディレクティブの変更のみ記載されていたが、命名の整合性のため JS 側の `invalid` も `isInvalid` に変更した（命名規則として `is-` プレフィックスは JS 状態変数名とも揃える方針を `front-style-naming.md` に明記）。
- **`stylelint-config-standard-scss` の `extends` を外した**: 規約準拠の前にデフォルトルールで 28 件のエラー（`rgba()` → `rgb()`、`0.6` → `60%`、`#ffffff` → `#fff`、ベンダープレフィックス禁止など）が出た。今回の ddoc の目的は「クラス命名規則の強制」のみのため、`extends` を外して `selector-class-pattern` のみを有効化する最小構成にした。デフォルトルールの導入は別 issue に切り出す方針。

### 確認・検証

- `pnpm svelte-check` — 0 errors / 0 warnings ✓
- `pnpm eslint .` — exit 0 ✓
- `pnpm lint:style` — exit 0 ✓

ブラウザでの目視確認は実施していない。CSS クラスのリネームのみで `var(--color-*)` などの参照には影響していないため見た目の変化はないはずだが、必要なら開発サーバーで確認すること。

### 気づき・備考

- **`.claude/rules/` のパススコープルールは初回利用**: `paths` frontmatter で対象ファイルを限定すると、AI Agent が該当ファイルを開いたタイミングでだけルールが読み込まれる。CLAUDE.md は全セッションで読み込まれるため、フロントエンド固有の詳細ルールはこの仕組みに移すと CLAUDE.md のコンテキスト消費を削減できる。
- **pnpm のストア移動が必要だった**: 環境変更（おそらく pnpm のグローバル設定変更）により、依存追加時に `ERR_PNPM_UNEXPECTED_STORE` が発生。`CI=true pnpm install` で全依存を新ストアに再リンクしてから Stylelint を追加した。
- **Stylelint 公式の Svelte サポート**: `customSyntax: "postcss-html"` を `overrides` で `*.svelte` に明示する形で動作確認できた。`stylelint` v17 + `postcss-html` v1.8 の組み合わせ。
- **`stylelint-config-standard-scss` の追加ルール導入余地**: 今回スコープ外とした 28 件は、色記法・ベンダープレフィックス・空行ルールなど、コードベース全体の品質向上に寄与する。別 issue で段階的に導入する価値はある。
- **誤検出を防ぐ事前調査の改善点**: 単純な `grep '\.[a-zA-Z]'` だと SVG 内 URL のドットも拾ってしまう。今後類似の調査を行う場合は、`<style>` ブロック内に絞った上で属性値を除外する工夫が必要。
