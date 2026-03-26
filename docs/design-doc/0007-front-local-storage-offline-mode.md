# 0007 非ログイン時 LocalStorage オフラインモード

> **scope**: front | **date**: 2026-03-26

## 概要

非ログイン時に LocalStorage をデータストアとして利用し、ログインなしでレコード・カテゴリ・支払い方法・請求レコードの CRUD を可能にする。API には手を加えない。

## 目標

- 非ログイン時に records, categories, payment_methods, invoice_records の CRUD がすべて動作する
- ログイン時は既存の API 通信をそのまま利用する
- ログインしても LocalStorage のデータはそのまま残す（破棄しない）

## 非目標

- API の変更（一切手を加えない）
- ログイン後にローカルデータをサーバーへ同期する
- ログイン時のローカルデータ破棄
- `front/src/lib/firebase/` 以下への変更
- 非ログイン時の集計 view（`fetchCategoryAggregation`, `fetchInvoiceRecordsWithdrawalAggregation`）のサポート
- ログイン UI の刷新

## 設計

### ログイン状態の判定

`auth.currentUser !== null` で同期的に判定する。`auth` は `firebase/index.svelte.ts` から既にエクスポートされているのでそのままインポートして使う。firebase 以下には変更を加えない。

### index.ts によるスイッチング

`front/src/lib/api/v1/index.ts` は既にモック切り替えのスイッチになっている（`flags.useMockApi ? mock : api`）。これを拡張して非ログイン時は `localStorageApi` に委譲するよう変更する。

現在は静的なデストラクチャで実装されているが、ログイン状態は動的に変わるため、関数呼び出し時に判定する `getImpl()` パターンに変える。

```typescript
// front/src/lib/api/v1/index.ts
import { flags } from '$lib/feature-flags';
import { auth } from '$lib/firebase/index.svelte';
import * as mock from './mock';
import * as api from './api';
import * as localApi from './localStorageApi';

const getImpl = () => {
  if (flags.useMockApi) return mock;
  return auth.currentUser !== null ? api : localApi;
};

export const fetchRecords: typeof api.fetchRecords = (...args) => getImpl().fetchRecords(...args);
export const createRecord: typeof api.createRecord = (...args) => getImpl().createRecord(...args);
// ... 全関数同様
```

`api.ts` と `localStorageApi.ts` は純粋な実装のままで、ログインチェックは `index.ts` に集約される。コンシューマ（各コンポーネント）は `$lib/api/v1` 経由で使っているため変更不要。

### LocalStorage キー

| キー                            | 型                              |
|---------------------------------|---------------------------------|
| `finascope_records`             | `Record[]`                      |
| `finascope_categories`          | `Category[]`                    |
| `finascope_payment_methods`     | `PaymentMethod[]`               |
| `finascope_invoice_records`     | `InvoiceRecord[]`               |

### ID 生成

`crypto.randomUUID()` でローカル ID を生成する。

### LocalStorage API 層

`front/src/lib/api/v1/localStorageApi.ts` を新規作成し、`api.ts` と同じシグネチャで LocalStorage を操作する関数を実装する。

**Records:**
- `fetchRecords(beginDate?, endDate?)` → `RecordsResponse`
- `createRecord(req)` → `CreateRecordResponse`
- `updateRecord(req)` → `UpdateRecordResponse`
- `deleteRecord(req)` → `CommonResponse`

**Categories:**
- `fetchCategories()` → `CategoriesResponse`
- `createCategory(req)` → `CreateCategoryResponse`
- `updateCategory(req)` → `UpdateCategoryResponse`

**PaymentMethods:**
- `fetchPaymentMethods()` → `PaymentMethodsResponse`
- `createPaymentMethod(req)` → `CreatePaymentMethodResponse`
- `updatePaymentMethod(req)` → `UpdatePaymentMethodResponse`

**InvoiceRecords:**
- `fetchInvoiceRecords(query)` → `InvoiceRecordsResponse`
- `createInvoiceRecord(req)` → `CommonResponse`
- `updateInvoiceRecord(req)` → `CommonResponse`
- `deleteInvoiceRecord(req)` → `CommonResponse`

**集計 view（空レスポンスを返す）:**
- `fetchCategoryAggregation()` → `{ aggregations: [] }`
- `fetchInvoiceRecordsWithdrawalAggregation()` → 型に合わせた空レスポンス

`Record` の `type`, `state`, `category`, `payment_method` フィールド（表示用ラベル）は、create/update 時に対応するローカルデータから解決して保存する。

## 変更ファイル一覧

- `front/src/lib/api/v1/localStorageApi.ts` — 新規作成。LocalStorage CRUD と空の集計レスポンスを実装
- `front/src/lib/api/v1/index.ts` — 静的デストラクチャから `getImpl()` パターンに変更し、`localStorageApi` を追加

## 実装ステップ

1. `localStorageApi.ts` を新規作成し、全リソースの LocalStorage CRUD・空集計を実装する
2. `index.ts` を `getImpl()` パターンに変更し、3 実装（mock / api / localApi）を切り替えるようにする
3. `pnpm svelte-check` で型エラーがないことを確認する

## 代替案

**`api.ts` の各関数内で分岐する案**: 各関数に `isLoggedIn()` チェックを書く方法。ログインチェックが散在して見通しが悪くなるため不採用。

**`apiBase` 内で一括分岐する案**: URL 文字列のパターンマッチが必要になり壊れやすいため不採用。

**Cookie でログイン状態を管理する案**: Firebase の `auth.currentUser` が同期的に使えるため不要。

## 未解決事項

- 非ログイン時のローカルデータが大量になった場合の上限制御（今回はスコープ外）
- ログイン/ログアウト時にローカルデータを破棄するかどうか（今回は破棄しない方針）
