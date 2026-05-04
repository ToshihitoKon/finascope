# CLAUDE.md

このファイルはリポジトリ内のコードを扱う際の Claude Code (claude.ai/code) へのガイダンスを提供します。

## プロジェクト概要

Finascope は個人財務管理アプリケーションで、マイクロサービスアーキテクチャを採用しています：
- バックエンド API: Ruby/Grape フレームワーク、ActiveRecord、MySQL
- フロントエンド: SvelteKit + TypeScript + Firebase Auth
- データベース: MySQL 8.0（ユーザーデータは暗号化）
- インフラ: Docker コンテナ + Nginx リバースプロキシ

## ディレクトリ構成

### バックエンド (`api/`)
- `app/api/`: API エンドポイント定義
  - `root.rb`: 認証ヘルパーを含むメイン API ルート
  - `v1/`: リソース別のバージョン付き API エンドポイント（categories, records, payment_methods, invoice_records, view）
  - `v1/entities/`: レスポンスシリアライズ用の Grape エンティティ
- `db/`: データベース層
  - `models.rb`: ActiveRecord モデル定義
  - `repositories.rb`: クエリメソッドを含むデータアクセス層
  - `connection.rb`: データベース接続設定
- `services/`: リソース別のビジネスロジック層
- `lib/`: ユーティリティライブラリ（ユーザーデータ暗号化、Firebase JWT 検証、ID 生成、例外）
- `constants.rb`: アプリケーション全体の定数
- `envs.rb`: 環境変数設定
- `scripts/`: データベースセットアップやコンソールアクセス用のユーティリティスクリプト

### フロントエンド (`front/`)
- `src/lib/`: 共有ライブラリ
  - `api/v1/`: 型定義とモックデータを含む API クライアント層
  - `firebase/`: Firebase 認証インテグレーション
  - `utils.ts`: ユーティリティ関数
- `src/routes/`: ファイルベースルーティングに従った SvelteKit ページ
- `src/app.html`, `src/app.css`: アプリケーションテンプレートとグローバルスタイル
- 設定ファイル: `package.json`, `svelte.config.js`, `tsconfig.json`, `vite.config.ts`

### インフラ
- `mysql/init.d/`: データベース初期化 SQL スクリプト
- `nginx/`: Nginx リバースプロキシ設定と Dockerfile
- `compose.yml`: 本番・開発環境用の Docker Compose 設定

### よく使うファイル
- API エンドポイント追加: `api/app/api/v1/[resource].rb`
- ページ追加: `front/src/routes/[page]/+page.svelte`
- データベースクエリ: `api/db/repositories.rb`
- ビジネスロジック: `api/services/[resource].rb`
- API 型定義: `front/src/lib/api/v1/types.d.ts`
- 定数: `api/constants.rb` と `front/src/lib/api/v1/const.ts`

## アーキテクチャパターン

### セキュリティモデル
プライバシーファーストの暗号化システムを実装しています：
- Firebase Auth UID によるユーザー識別
- ユーザー固有のハッシュによるデータ暗号化（`api/lib/user_hash.rb` 参照）
- 別のソルトで隔離されたユーザーデータテーブル（`UserHash#user_info_hash`）
- ユーザーデータと他テーブル間に直接の外部キー関係なし

### API 構造
- フレームワーク: Grape API（JSON 形式）
- 認証: Firebase JWT Bearer トークン
- エンティティ: レスポンスシリアライズ用 Grape エンティティ（`api/app/api/v1/entities/`）
- サービス: ビジネスロジック層（`api/services/`）
- リポジトリ: データアクセス層（`api/db/repositories.rb`）

### フロントエンドアーキテクチャ
- フレームワーク: SvelteKit 5 + TypeScript
- 認証: Firebase Auth + JWT トークン管理
- API クライアント: `front/src/lib/api/v1/api.ts` に実装予定

### フロントエンド実装ガイドライン

フロントエンドのファイル構成・スタイリング方針・CSS クラス命名規則は `.claude/rules/` に分離されている。`front/` 配下のファイルを編集する際に自動的に読み込まれる。

- `.claude/rules/front-component-structure.md` — ファイル構成、CSS/SCSS 変数規約、Svelte 5 の注意点
- `.claude/rules/front-style-naming.md` — CSS クラス命名規則（`layout-` / `style-` / `is-` / `has-`）

### データベース設計
- モデル: `api/db/models.rb` の ActiveRecord モデル
- 暗号化: 機密フィールドは `encrypted_` プレフィックス付き
- ページネーション: Kaminari gem
- 接続: `api/db/connection.rb` 経由で MySQL

## 実装上の重要な注意点

### ユーザーデータ暗号化
ユーザーの機密データはすべて `UserHash` クラスで暗号化します：
```ruby
uhash = UserHash.new(firebase_uid)
encrypted_data = uhash.encrypt(sensitive_string)
decrypted_data = uhash.decrypt(encrypted_data)
```

### API 認証
すべての API エンドポイントは Firebase JWT トークンを要求します：
```ruby
# API ヘルパー内 (api/app/api/root.rb)
def request_userdata
  jwt = authorization_header&.gsub("Bearer ", "")
  Firebase.decode_jwt(jwt)
end
```

### フロントエンド API 通信
API 呼び出しには Firebase JWT トークンを含めます：
```typescript
// front/src/lib/api/v1/api.ts に実装予定
const jwt = await getFirebaseToken();
opts.headers['Authorization'] = `Bearer ${jwt}`;
```

### TODO アイテム処理（非推奨）
カテゴリや支払い方法が未設定のレコードには特別な TODO ID を使用します：

TODO ID 定数:
- フロントエンド: `front/src/lib/api/v1/const.ts` - `TodoIds.Category` と `TodoIds.PaymentMethod`（実装予定）
- バックエンド: `api/constants.rb` - `TODO_ID[:category]` と `TODO_ID[:payment_method]`
- 値: `'TODO_CATEGORY_ID'` と `'TODO_PAYMENT_METHOD_ID'`

実装詳細:
- カテゴリ未設定のレコードは `category_id: 'TODO_CATEGORY_ID'` で作成可能
- TODO アイテムは一覧・集計の両方で「TODO」として表示される
- フロントエンドのレコード作成ダイアログにはデフォルトオプションとして TODO を含める予定（実装予定）
- バックエンドリポジトリは `left_joins(:category)` で集計に TODO アイテムを含める
- TODO レコードは作成・編集・集計が完全に機能する

カテゴリ集計における TODO アイテム:
TODO アイテムは `/view/categories/aggregation` で独立した「TODO」カテゴリとして表示され、クリックで詳細レコードを確認できます。

## 型チェック

### フロントエンド

フロントエンドの型チェックは `svelte-check` で行う（TypeScript + Svelte テンプレートの両方をチェックする）：

```bash
cd front
pnpm svelte-check
```

`tsc --noEmit` は TypeScript のみのチェックで、Svelte テンプレート内の型エラーは検出されないため使わない。

型チェックが通らない場合の確認事項:
- `.svelte-kit/` の型が古い場合は `pnpm svelte-kit sync` で再生成する
- `sass-embedded` が必要（`svelte-check` が SCSS プリプロセスに使用する）

## Lint チェック

### フロントエンド

ESLint と Stylelint は `svelte-check` とは別に実行する：

```bash
cd front
pnpm eslint
pnpm lint:style
```

コード変更後は `svelte-check`, `eslint`, `lint:style` の 3 つすべてをパスさせること。

`lint:style` は CSS クラス命名規則（`layout-` / `style-` / `is-` / `has-`）を強制する。詳細は `.claude/rules/front-style-naming.md` を参照。

ESLint の注意事項や Svelte 5 関連の注意点は `.claude/rules/front-component-structure.md` に記載されている。

## API テスト実行

前提: `compose-dev-middleware.yml` の MySQL が起動済みであること（起動していなければスクリプトが自動起動する）。

```bash
./scripts/test/api-test.sh
```

内部では `compose-dev-test-api.yml` の `api-test` コンテナで `bundle exec rake test` を実行する。rake test は `test:prepare_db`（finascope_test DB の作成）と `test:rspec`（rspec 実行）を順に呼ぶ。

コンテナ内で直接 rspec を実行したい場合:
```bash
docker compose -f compose-dev-test-api.yml exec api-test bundle exec rspec
```

## データベース操作

コンソールアクセス:
```bash
cd api
bundle exec ruby scripts/finascope-console.rb
```

## デプロイメント

- フロントエンドは静的アセットをビルドする: `pnpm build`
- 本番デプロイは SvelteKit の static adapter を使用
- GCP デプロイは `pnpm deploy` スクリプトで設定済み
- 環境変数は Docker compose ファイルで管理

## AI Agent による変更実行前の Design Doc 作成

実装・リファクタリング・大きな変更を AI Agent に実行させる前に、`/make-ddoc` スキルを使って Design Doc を作成することを強く推奨する。

**対象となる作業の例:**
- 新機能の実装
- 既存コードのリファクタリング
- API・データベーススキーマの変更
- フロントエンドの大規模な改修

**運用フロー:**
1. `/make-ddoc` を実行して Design Doc を作成・保存する
2. Design Doc を AI Agent に参照させてから実装を依頼する

Design Doc を事前に作成することで、実装方針のズレや手戻りを防ぎ、AI Agent の出力品質が向上する。
