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

ファイル構成の役割分担:
- UI 要素（テーブル、フォーム、サイドバーなど）は `src/lib/components/` に実装する
- `src/routes/+page.svelte` にはコンポーネントのインポート・配置、ページ固有の状態管理・TypeScript、ページレベルのレイアウト・スタイルを記述する
- `src/lib/components/index.ts` でコンポーネントをまとめてエクスポートする

スタイリング方針:
- グローバル CSS 変数とグローバル SCSS 変数は `src/app.scss` に定義する
- CSS/SCSS 変数命名規則: `--{type}-{role}` 形式（CSS変数）、`${type}-{role}`（SCSS変数）
  - タイプ接頭辞: `color`, `px`, `rem`, `font` など
  - 例: `--color-primary`, `--px-sidebar-width`, `--px-main-max-width`
- コンポーネントスタイルでは `var(--variable-name)` でグローバル CSS 変数を参照する
- メディアクエリのブレークポイント計算には SCSS 変数を使用する（`@media (max-width: #{$px-sidebar-width + $px-main-max-width})`）
  - dart-sass では `@media` 内の算術式を `#{}` で補間する必要がある

クラス名のプレフィックスルール:
- `layout-` クラス: DOM の配置・レイアウトに関するスタイル（`display`, `flex`, `position`, `margin`, `padding`, `text-align` など）
  - 例: `layout-container`, `layout-summary`, `layout-money`, `layout-center`
- `style-` クラス: 色・フォント・ボーダーなど見た目に関するスタイル（`color`, `background`, `border`, `font-size` など）
  - 例: `style-table`, `style-button`, `style-divider`
- 両方の性質を持つ要素には `layout-foo style-foo` のように両クラスを付与する
- 各 Svelte ファイルの `<style>` ブロック内で `layout-*` と `style-*` を分けて記述する

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
