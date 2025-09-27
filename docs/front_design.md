# 家計簿アプリ設計仕様書

## 概要
Svelte + Bits UI を使用した家計簿アプリケーションの設計仕様書です。
トップページ中心のシームレスな入力体験を重視し、CRUD操作を分離しない設計を採用します。

## 技術スタック
- **フロントエンド**: Svelte + SvelteKit
- **UIライブラリ**: Bits UI
- **スタイリング**: Tailwind CSS（インラインクラス中心）
- **API**: 既存のRESTful API（Swagger定義済み）
- **対象デバイス**: PC（デスクトップファースト）

## スタイル指針
- **シンプル第一**: 個人利用のため、装飾は最小限
- **アニメーション**: 必要最低限（ローディング、ホバー程度）
- **色使い**: グレースケール中心、アクセントカラーは紅梅色（#E86B79）
- **レイアウト**: テーブル中心の実用的なデザイン

### CSS管理方針
- **Tailwind CSS**: margin/padding などのレイアウト系ユーティリティクラスを使用
- **components.css**: 色、ボーダー、フォントサイズなど見た目に関する共通スタイルを定義
- **保守性重視**: 共通コンポーネントのスタイルは `src/components.css` で一元管理
- **一貫性確保**: デザイントークン（色、サイズ等）は共通スタイルで統一

### 共通CSSクラス
```css
/* カード系 */
.card              /* 基本カード */
.card-summary      /* サマリー用カード */

/* ボタン系 */
.btn-primary       /* メインアクション（紅梅色） */
.btn-secondary     /* セカンダリアクション */
.btn-danger        /* 削除等の危険アクション */

/* フォーム系 */
.form-input        /* テキスト入力 */
.form-select       /* セレクトボックス */
.checkbox          /* チェックボックス */

/* リンク系 */
.link-accent       /* アクセントカラーリンク */

/* テーブル系 */
.table-container   /* テーブル全体 */
.table-header      /* テーブルヘッダー */
.table-row         /* テーブル行 */
.table-input-row   /* 新規入力行 */
```

## ページ構成
```
/                    # メインページ（全機能統合）
/summary            # 高度な集計・分析ページ
/settings           # 設定ページ（カテゴリ・支払方法管理）
```

## メインページ（/）の構成要素

### 1. ヘッダーサマリー
- 今月の支出合計金額
- 主要カテゴリ別金額（上位3-4項目）

### 2. 支払方法別サマリー
- 各支払方法の今月の利用金額
- クレジットカードの場合は引き落とし日も表示
- 現金、各種カード、電子マネーなど

### 3. 明細一覧テーブル
- 日付、金額、カテゴリ、支払方法、摘要、操作列
- 最新の明細が上部に表示（降順）
- ページネーションまたは無限スクロール

### 4. 新規入力行（テーブル最下部）
- 常時表示の入力フォーム
- 日付：デフォルトで今日、変更可能
- 金額：数値入力
- カテゴリ：セレクトボックス
- 支払方法：セレクトボックス
- 摘要：テキスト入力
- 追加ボタン

## コア機能仕様

### データの永続化
- **即座保存**: 明細追加時にAPI経由で即座にDB保存
- **楽観的更新**: UI上では即座に反映、APIエラー時は差し戻し
- **状態管理**: Svelte stores でクライアント側状態管理

### 明細編集・削除
- **インライン編集**: テーブル行をクリックで編集モードに切り替え
- **削除**: 削除ボタンクリックで確認ダイアログ表示後削除
- **一括操作**: チェックボックスで複数選択、一括削除機能

## データ構造

### Record（明細）
```typescript
interface Record {
  id: number;
  date: string;           // YYYY-MM-DD形式
  amount: number;         // 金額
  category: string;       // カテゴリ名
  payment_method: string; // 支払方法名
  description?: string;   // 摘要
  created_at: string;
  updated_at: string;
}
```

### Category（カテゴリ）
```typescript
interface Category {
  id: number;
  name: string;
  created_at: string;
  updated_at: string;
}
```

### PaymentMethod（支払方法）
```typescript
interface PaymentMethod {
  id: number;
  name: string;
  withdrawal_day?: number; // 引き落とし日（1-31）
  created_at: string;
  updated_at: string;
}
```

## 状態管理設計

### Svelte Stores
```typescript
// stores/records.ts
export const records = writable<Record[]>([]);
export const categories = writable<Category[]>([]);
export const paymentMethods = writable<PaymentMethod[]>([]);

// 計算済み状態
export const monthlyTotal = derived(records, ($records) => {
  // 今月の合計金額を計算
});

export const categoryTotals = derived(records, ($records) => {
  // カテゴリ別合計を計算
});

export const paymentMethodTotals = derived([records, paymentMethods], ([$records, $paymentMethods]) => {
  // 支払方法別合計を計算
});
```

### API連携
```typescript
// lib/api.ts
export const api = {
  records: {
    getAll: () => fetch('/api/v1/records').then(r => r.json()),
    create: (data: Omit<Record, 'id' | 'created_at' | 'updated_at'>) => 
      fetch('/api/v1/records', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
      }).then(r => r.json()),
    update: (id: number, data: Partial<Record>) =>
      fetch(`/api/v1/records/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
      }).then(r => r.json()),
    delete: (id: number) =>
      fetch(`/api/v1/records/${id}`, { method: 'DELETE' })
  }
  // categories, paymentMethods も同様
};
```

### ディレクトリ構造
```
src/
├── lib/
│   ├── components/
│   │   ├── ui/           # Bits UI components
│   │   ├── RecordTable.svelte
│   │   ├── RecordForm.svelte
│   │   └── Summary.svelte
│   ├── stores/
│   │   ├── records.ts
│   │   ├── categories.ts
│   │   └── paymentMethods.ts
│   ├── api.ts
│   └── utils.ts
├── routes/
│   ├── +layout.svelte
│   ├── +page.svelte      # メインページ
│   ├── summary/
│   └── settings/
└── app.html
```
