# 0008 レコード追加フォームの日付入力改修

> **scope**: front | **date**: 2026-04-21

## 概要

レコード追加フォームの日付入力を、bits-ui の `DateField`（セグメント形式）から、年・月・日それぞれの `input[type=number]` 3つ並べる形式に変更する。PC・モバイル両方で使いやすく、日付バリデーションも実装する。

## 目標

- `ExpenseDetails.svelte` の新規入力行の日付入力を `input[type=number]` × 3 に変更
- 存在しない日付（例：2月30日、13月など）の入力時にエラーを表示
- PC・モバイル両方で快適に入力できる UI にする

## 非目標

- `InvoiceRecordTableForm.svelte` の日付（自動計算）は変更しない
- カレンダーピッカー UI の追加
- `DateField.svelte` コンポーネントの削除（他で使われる可能性を残す）

## 設計

### フロントエンド設計

#### 新しい日付入力コンポーネント: `NumberDateField.svelte`

`DateField.svelte` と同じ props インターフェースにして差し替えを最小化する。

```
props:
  value: { year: number, month: number, day: number } | undefined  ($bindable)
  onValidationError: (msg: string | null) => void  (省略可)
```

内部で年・月・日を個別の `$state` として持ち、いずれかが変更されたとき日付バリデーションを実行して `value` を更新する。

#### レイアウト

テーブルセル内に横並びで配置：

```
[ 2026 ] / [ 04 ] / [ 21 ]
  yyyy       mm      dd
```

- 年: `min=1900 max=2100 maxlength=4`
- 月: `min=1 max=12 maxlength=2`
- 日: `min=1 max=31 maxlength=2`（バリデーションで月ごとの最大日を確認）

#### バリデーション

年・月・日のいずれかの input がアクティブな状態から、3つすべてがアクティブでなくなったタイミングで1回だけ実行する。

実装方法: `focusout` イベントで `event.relatedTarget` を確認し、次のフォーカス先がコンポーネント内の input であれば何もしない。コンポーネント外に出たときだけバリデーションを走らせる。

バリデーション内容: `new Date(year, month-1, day)` を生成し、得られた日付オブジェクトの年月日が入力値と一致するか確認する（JavaScript の Date はオーバーフローを自動補正するため、不一致で不正な日付を検出できる）。

エラー時: `value` を `undefined` にセット。`handleCreate` 内で `newDate === undefined` のときに `toast.error` でガード。

#### `ExpenseDetails.svelte` での変更点

- `newDate` の型を `CalendarDate | undefined` → `{ year: number, month: number, day: number } | undefined` に変更
- `DateField` を `NumberDateField` に差し替え
- `dateStr` 変換ロジックを新しい型に合わせて修正

## 変更ファイル一覧

- `front/src/lib/components/NumberDateField.svelte` — **新規作成**。年・月・日の `input[type=number]` を並べたコンポーネント。バリデーション込み。
- `front/src/lib/components/index.ts` — `NumberDateField` をエクスポートに追加
- `front/src/lib/components/ExpenseDetails.svelte` — `DateField` → `NumberDateField` に差し替え、`newDate` の型と `dateStr` 変換を修正

## 実装ステップ

1. `NumberDateField.svelte` を新規作成
   - 年・月・日の `input[type=number]` を横並びで配置
   - 入力変更時に日付バリデーションを実行
   - 不正日付のとき `value` を `undefined` にセット
2. `front/src/lib/components/index.ts` に `NumberDateField` をエクスポート追加
3. `ExpenseDetails.svelte` を修正
   - import を `DateField` → `NumberDateField` に変更
   - `newDate` の型を変更（`@internationalized/date` の import も削除）
   - `dateStr` 変換を新しい型に合わせて修正
   - `handleCreate` のバリデーションを調整（`newDate` が `undefined` のときエラー）
4. `pnpm svelte-check` と `pnpm eslint` でエラーがないことを確認

## 代替案

- **bits-ui DateField のまま SP スタイル調整**: bits-ui のセグメント入力はモバイルで数字キーボードが出にくく、タップ精度も必要で改善しにくい。採用しない。
- **input[type=date]**: ブラウザ・OS によって UI が大きく異なり、PC では年入力が4桁全部打たないと確定しない挙動が使いにくい。採用しない。

## 未解決事項

- なし

---

## 実装サマリー

> **実装日**: 2026-04-21

### 変更ファイル

- `front/src/lib/components/NumberDateField.svelte` — 新規作成。年・月・日を `type=text` + `inputmode=numeric` で横並び、focusout 時にゼロパディング正規化とバリデーション実行
- `front/src/lib/components/index.ts` — `NumberDateField` をエクスポート追加
- `front/src/lib/components/ExpenseDetails.svelte` — `DateField` → `NumberDateField` に差し替え、`newDate` 型変更、既存行の日付表示を `date-sep` span で統一

### 実装内容

ddoc の設計通りに実装した。主な変更点：

- 月・日を `type=number` ではなく `type=text` + `inputmode=numeric` に変更。`type=number` ではゼロパディング表示を制御できないため。
- バリデーションは `focusout` イベントで `relatedTarget` を確認し、コンポーネント外にフォーカスが出たときのみ実行。
- invalid 時は赤下線 + 淡い赤背景でスタイル表示し、追加ボタン押下時に `toast.error('日付が不正です')` を表示。
- 既存行の日付表示も `date-sep` クラスの span（`padding: 0 2px`）で区切り、入力行と同じスペーシングに統一。
- 全 input/select に常時下線（`var(--color-border)`）を追加し、非アクティブ時も入力欄として認識できるようにした。

### 確認・検証

- `pnpm svelte-check` — エラーなし
- `pnpm eslint` — エラーなし

### 気づき・備考

- `{@const}` は `<td>` 直下に置けない（`{#each}` 等のブロック内のみ有効）。既存行の日付分割はインラインの `split('-')[n]` で対応。
- `type=number` の input は OS・ブラウザによって spinner が表示されたりゼロパディングが無視されたりするため、数字入力でも `type=text` + `inputmode=numeric` の組み合わせが使いやすい。
