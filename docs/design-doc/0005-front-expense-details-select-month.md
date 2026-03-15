# [0005] 支払い一覧の確認月切り替え対応

> **scope**: front | **date**: 2026-03-15

## 概要

支払い一覧（ExpenseDetails）とカテゴリ集計（MonthlyExpenses）で表示する月を切り替えられるようにする。
`svelte/store` で月状態を共有し、両コンポーネントが同期して更新される。

## 目標

- 支払いテーブルで月を指定でき、指定した月のレコードのみが表示される
- カテゴリ集計（MonthlyExpenses）も同じ月で連動して更新される
- デフォルトは現在の月

## 非目標

- 細かいスタイルの修正
- 月選択以外のフィルタリング（カテゴリ・支払い方法など）

## 設計

### 月状態のストア

`svelte/store` で年・月を管理する `selectedMonth` ストアを作成する。

```typescript
// front/src/lib/stores/selectedMonth.ts
import { writable, derived } from 'svelte/store';

const now = new Date();
export const selectedYear = writable<number>(now.getFullYear());
export const selectedMonth = writable<number>(now.getMonth() + 1);

// begin_date / end_date を自動計算する derived store
export const selectedMonthRange = derived(
  [selectedYear, selectedMonth],
  ([$year, $month]) => {
    const begin = `${$year}-${String($month).padStart(2, '0')}-01`;
    const lastDay = new Date($year, $month, 0).getDate();
    const end = `${$year}-${String($month).padStart(2, '0')}-${String(lastDay).padStart(2, '0')}`;
    return { beginDate: begin, endDate: end };
  }
);
```

### 月選択UI（MonthSelector コンポーネント）

`front/src/lib/components/MonthSelector.svelte` を新規作成する。

UIの構成:
- `◀` ボタン: 前月へ
- 年セレクトボックス（現在年 ± 数年）
- 月セレクトボックス（1〜12月）
- `▶` ボタン: 翌月へ

ストアを直接読み書きする（propsでのバインドは不要）。

### `+page.svelte` の変更

- `selectedMonthRange` ストアを参照して `loadData` に `beginDate`/`endDate` を渡す
- `loadData` を `$effect` で監視し、ストアが変わるたびに自動再取得する
- `MonthSelector` をページ上部に配置する
- `ExpenseDetails` の `records` / `onRefresh` props を削除する（不要になる）

### `ExpenseDetails.svelte` の変更

- `records` prop・`onRefresh` prop を削除する
- `selectedMonthRange` ストアを購読し、コンポーネント内で `fetchRecords` を呼ぶ
- `createRecord` 後の再取得もコンポーネント内で完結する

### API呼び出し変更

現在の `fetchRecords(query: string)` は query string をそのまま渡す形だが、
`fetchCategoryAggregation` と同様に `beginDate`/`endDate` を引数で受け取る形に変更する。

```typescript
// 変更後
export const fetchRecords = async (
  beginDate?: string,
  endDate?: string
): Promise<apitype.RecordsResponse> => {
  const params = new URLSearchParams();
  if (beginDate) params.set('begin_date', beginDate);
  if (endDate) params.set('end_date', endDate);
  const query = params.toString();
  return apiBase(`v1/records${query ? `?${query}` : ''}`, 'GET', {});
};
```

mock も同様に変更する。

## 変更ファイル一覧

- `front/src/lib/stores/selectedMonth.ts` — **新規作成**。年・月の writable store と begin_date/end_date を計算する derived store
- `front/src/lib/components/MonthSelector.svelte` — **新規作成**。前後ボタン＋年月セレクトボックスのUI。ストアを直接操作する
- `front/src/lib/components/index.ts` — `MonthSelector` をエクスポートに追加
- `front/src/lib/api/v1/api.ts` — `fetchRecords` のシグネチャを `(beginDate?, endDate?)` に変更
- `front/src/lib/api/v1/mock/index.ts` — mock の `fetchRecords` シグネチャを同様に変更
- `front/src/lib/components/ExpenseDetails.svelte` — `records`/`onRefresh` props を削除し、ストアを購読して自律的にデータ取得
- `front/src/routes/+page.svelte` — `loadData` をストアベースに変更、`MonthSelector` を配置、`ExpenseDetails` へのprops削除

## 実装ステップ

1. `front/src/lib/stores/selectedMonth.ts` を新規作成する
2. `front/src/lib/api/v1/api.ts` と `mock/index.ts` の `fetchRecords` シグネチャを変更する
3. `front/src/lib/components/MonthSelector.svelte` を新規作成する
4. `front/src/lib/components/index.ts` に `MonthSelector` を追加する
5. `front/src/lib/components/ExpenseDetails.svelte` を修正する（props削除・ストア購読・自律fetch）
6. `front/src/routes/+page.svelte` を修正する（`loadData` のストア対応・`MonthSelector` 配置・props整理）
7. `pnpm svelte-check` で型チェックを通す

## 代替案

- **onRefresh に引数を渡す案**: 親が月状態を持って `onRefresh(beginDate, endDate)` 形式にする案。シンプルだが `MonthlyExpenses` との連動を考えると結局ストアが必要になるため不採用。
- **Context API**: ページ内ツリーでのみ共有するならContextでも可だが、store の方が Svelte の標準的な使い方に沿っており、将来的な拡張もしやすいため store を採用。

## 未解決事項

- 年セレクトボックスの選択可能範囲（現在年 ± 何年か）は実装時に適当に決める

---

## 実装サマリー

> **実装日**: 2026-03-15

### 変更ファイル

- `front/src/lib/stores/selectedMonth.ts` — 新規作成。年・月のwritable store + begin/end dateのderived store
- `front/src/lib/components/MonthSelector.svelte` — 新規作成。◀ 年セレクト 月セレクト ▶ のUI。ストアを直接操作
- `front/src/lib/components/index.ts` — `MonthSelector` をエクスポートに追加
- `front/src/lib/api/v1/api.ts` — `fetchRecords` を `(beginDate?, endDate?)` シグネチャに変更
- `front/src/lib/api/v1/mock/index.ts` — `fetchRecords` / `fetchCategoryAggregation` 両方のシグネチャを統一、mockレコードの日付を引数の年月に連動させる対応も追加
- `front/src/lib/components/ExpenseDetails.svelte` — `records`/`onRefresh` props を削除し、`$effect` でストアを購読して自律fetch
- `front/src/routes/+page.svelte` — `MonthSelector` 配置、`$effect` でカテゴリ集計をストア連動に変更、`ExpenseDetails` へのprops削除

### 実装内容

設計通りに進んだ。`svelte/store` で年・月を共有し、`ExpenseDetails` と `MonthlyExpenses`（親経由）が同じ月で連動して更新される。`MonthSelector` は ◀▶ ボタンで月またぎも正しくハンドルする（12月→翌年1月など）。年の選択範囲は現在年 ± 3年（計7年）とした。

ddocには記載がなかったが、mockの `fetchCategoryAggregation` のシグネチャも `params: string` のままで `api.ts` と不一致だったため合わせて修正した。また、mockレコードの日付が固定値だと月切り替えの動作確認ができないため、`beginDate` の年月をレコードの日付に反映するよう修正した。

### 確認・検証

`pnpm svelte-check` → 0 errors, 0 warnings

### 気づき・備考

- `$effect` は Svelte 5 Runes の機能で、ストアの変化を自動追跡して再実行される。`onMount` + store subscribe の組み合わせより簡潔に書ける
- mockの日付を動的にすることでブラウザ上での月切り替え動作確認が容易になった
