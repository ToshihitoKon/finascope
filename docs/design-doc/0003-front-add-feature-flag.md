# 0003 feature flag による mock/実API 切り替え

> **scope**: front | **date**: 2026-03-14

## 概要

フロントエンドに feature flag 機構を導入し、設定ファイルを1箇所変更するだけで mock と実 API を切り替えられるようにする。将来的には API から feature flag を取得する拡張も想定する。

## 目標

- `front/src/lib/feature-flags.ts` の値を変えるだけで mock/実 API を全体的に切り替えられる
- 各ページ・コンポーネントは `$lib/api/v1`（index.ts）だけを import すれば良い状態にする
- 将来的に UI の機能 ON/OFF など他の flag も追加できる拡張性を持たせる

## 非目標

- エンドポイントごとの個別切り替え（全体一括切り替えのみ）
- API・DB への feature flag 設定機能の実装（今回はメモのみ）
- ブラウザから動的に切り替える UI（開発者が設定ファイルを編集して切り替える）

## 設計

### feature-flags.ts

```ts
// front/src/lib/feature-flags.ts
export const flags = {
  useMockApi: true,  // true: mock, false: 実API
} as const;
```

将来的に API から flag を取得する場合は、この値を API レスポンスで上書きする仕組みを追加する。

### api/v1/index.ts（切り替えの口）

```ts
// front/src/lib/api/v1/index.ts
import { flags } from '$lib/feature-flags';
import * as mock from './mock';
import * as api from './api';

export const {
  fetchRecords,
  createRecord,
  updateRecord,
  deleteRecord,
  fetchCategories,
  createCategory,
  updateCategory,
  fetchPaymentMethods,
  createPaymentMethod,
  updatePaymentMethod,
  fetchInvoiceRecords,
  createInvoiceRecord,
  updateInvoiceRecord,
  deleteInvoiceRecord,
  fetchCategoryAggregation,
  fetchInvoiceRecordsWithdrawalAggregation,
} = flags.useMockApi ? mock : api;
```

### import の統一

各ページ・コンポーネントの import を `$lib/api/v1/mock` や `$lib/api/v1/api` から `$lib/api/v1` に変更する。

変更対象:
- `front/src/routes/+page.svelte`: `$lib/api/v1/mock` → `$lib/api/v1`
- `front/src/lib/components/ExpenseDetails.svelte`: `$lib/api/v1/mock` → `$lib/api/v1`
- `front/src/lib/components/InvoiceRecordTableForm.svelte`: `$lib/api/v1/api` → `$lib/api/v1`

## 変更ファイル一覧

- `front/src/lib/feature-flags.ts` — 新規作成。feature flag の定義ファイル
- `front/src/lib/api/v1/index.ts` — flag に応じて mock か api を re-export する口として実装
- `front/src/routes/+page.svelte` — import を `$lib/api/v1/mock` → `$lib/api/v1` に変更
- `front/src/lib/components/ExpenseDetails.svelte` — import を `$lib/api/v1/mock` → `$lib/api/v1` に変更
- `front/src/lib/components/InvoiceRecordTableForm.svelte` — import を `$lib/api/v1/api` → `$lib/api/v1` に変更

## 実装ステップ

1. `front/src/lib/feature-flags.ts` を新規作成し、`useMockApi` flag を定義する
2. `front/src/lib/api/v1/index.ts` に flag に応じた re-export を実装する
3. 各ページ・コンポーネントの import を `$lib/api/v1` に統一する
4. `pnpm svelte-check` で型チェックを通す

## 代替案

### 環境変数（`$env/static/public`）で切り替える

SvelteKit の `$env/static/public` を使い、ビルド時に切り替える方法。`.env` ファイルで管理できるメリットがあるが、変更のたびに再ビルドが必要になる。また、将来 API から flag を取得して上書きする設計と相性が悪いため不採用。

### URL クエリパラメータやローカルストレージで動的切り替え

ブラウザから動的に切り替えられるが、開発者のみが使う機能にしては複雑すぎる。不採用。

## 未解決事項

- **API による feature flag 取得（将来拡張）**: feature flag を API エンドポイントで管理し、フロントが起動時に取得して `flags` を動的に上書きする仕組み。その場合 DB にフラグ設定テーブルが必要になる。今回は実装しないが、`feature-flags.ts` の構造はこの拡張を妨げないよう設計する。
- **`mock/index.ts` の `fetchInvoiceRecords` シグネチャ**: 実 API 側（`api.ts`）は `query: string` を引数に取るが、mock 側は引数なし。index.ts で re-export する際に型不一致が出る可能性があるため、実装時に確認・修正が必要。
