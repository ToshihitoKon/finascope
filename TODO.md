# TODOチェックリスト

## フロントエンド（優先度：高）

### ダッシュボードコンポーネント - API連携
- [ ] MainCategories: `fetchCategoryAggregation()` を接続してデータ表示
- [ ] MonthlyExpenses: 集計ロジックを実装
- [ ] PaymentMethodsSummary: `fetchPaymentMethods()` を接続してデータ表示
- [ ] ExpenseDetails: `fetchRecords()` + CRUD操作を接続
- [ ] すべてのAPI呼び出しにローディング状態を追加
- [ ] エラー時のフォールバック表示を追加

### コアインフラ
- [ ] `lib/api/v1/index.ts` でAPI関数、型、定数をエクスポート

### ページ実装
- [ ] `/records` - レコード一覧・編集ページ
- [ ] `/categories` - カテゴリ管理ページ
- [ ] `/payment-methods` - 支払方法管理ページ

### ナビゲーション・レイアウト
- [ ] サイドバーまたはヘッダーナビゲーション
- [ ] ページルーティング実装

### フォーム
- [ ] レコード作成・編集フォーム
- [ ] カテゴリ作成・編集フォーム
- [ ] 支払方法作成・編集フォーム

### 設定・テスト
- [ ] Firebase設定を環境変数に移行
- [ ] Vitest + SvelteKitテストユーティリティのセットアップ
- [ ] コンポーネントテストを追加

---

## バックエンド（優先度：中）

### セキュリティ（重要）
- [ ] **重要**: `api/lib/user_hash.rb:26` の暗号化IVを修正 - 固定IVではなくランダムIVを使用

### API品質
- [ ] パラメータバリデーション修正: `api/app/api/v1/records.rb:40,77` で `require` を `requires` に変更
- [ ] `api/app/api/v1/invoice_records.rb` のパラメータバリデーション修正
- [ ] `params do` ブロックをHTTPメソッドブロックの外に移動
- [ ] `api/app/api/root.rb` に `rescue_from` ブロックを追加して適切なエラーハンドリング
- [ ] 例外使用を統一（すべて `Exceptions::InvalidArgument` を使用）
- [ ] デバッグ用 `puts` 文を削除（`api/app/api/v1/invoice_records.rb:49` と `api/app/api/root.rb:29`）

### パフォーマンス
- [ ] リポジトリメソッドのN+1クエリを確認
- [ ] リポジトリレイヤーの `eager_load` 使用を最適化
- [ ] 大量データでのクエリパフォーマンステスト

### コード品質
- [ ] 共通バリデーションロジックを共有モジュールに抽出
- [ ] `api/services/invoice_records.rb:45-79` の `monthly_records` メソッドをリファクタリング
- [ ] `api/db/repositories.rb:16-54` のマジックナンバーを定数に置換
- [ ] すべてのAPIエンドポイントに包括的な入力バリデーションを追加

### 技術的負債
- [ ] コードベース内のTODOコメントを確認・解決
- [ ] サービスとリポジトリのメソッドドキュメントを追加
- [ ] ビジネスロジックと使用例をドキュメント化
