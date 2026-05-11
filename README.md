# Finascope

Finascope は個人財務管理アプリケーションです。ユーザーデータには最低限の簡易的な暗号化を施して保存しています。

## アーキテクチャ

マイクロサービス構成:

- **バックエンド API**: Ruby / Grape / ActiveRecord
- **フロントエンド**: SvelteKit + TypeScript + Firebase Auth
- **データベース**: MySQL 8.0（ユーザーデータは暗号化）
- **インフラ**: Docker + Nginx リバースプロキシ

## ディレクトリ構成

```
.
├── api/                 # バックエンド API (Ruby/Grape)
│   ├── app/api/         # API エンドポイント (v1/)
│   ├── db/              # モデル・リポジトリ・接続設定
│   ├── services/        # ビジネスロジック層
│   └── lib/             # 暗号化・JWT 検証などのユーティリティ
├── front/               # フロントエンド (SvelteKit)
│   ├── src/lib/         # API クライアント・Firebase 連携
│   └── src/routes/      # ページ (ファイルベースルーティング)
├── mysql/init.d/        # DB 初期化 SQL
├── nginx/               # リバースプロキシ設定
├── docs/design-doc/     # 設計ドキュメント
└── compose.yml          # Docker Compose 設定
```

## 主要な設計方針

### ユーザーデータの取り扱い

- Firebase Auth UID でユーザーを識別
- `UserHash` クラスでユーザー固有のソルトを用いた簡易的な暗号化を行う（強固な保護を目的とした設計ではない）
- ユーザーデータと他テーブルの間に直接の外部キー関係を持たない

### API

- Grape ベースの JSON API
- Firebase JWT Bearer トークンによる認証
- レスポンスは Grape Entity でシリアライズ

## セットアップ

### 必要なもの

- Docker / Docker Compose
- `make`

### 開発環境の起動

開発環境は middleware (MySQL) / API / フロント の 3 つの compose ファイルに分かれており、`make` ターゲット経由で起動する。

```bash
make dev-middleware   # MySQL などのミドルウェア
make dev-api          # API サーバー
make dev-front        # フロントエンド
```

ログを追う:

```bash
make logs-api
make logs-front
make logs              # すべて
```

停止・後片付け:

```bash
make clean
```

利用可能なターゲット一覧は `make help` で確認できる。

### よく使う操作

```bash
make schema-update    # DB スキーマ更新
make console          # API コンテナ内で Rails 風コンソール
make api-shell        # API コンテナへ bash で入る
make db-shell         # MySQL クライアントで DB に接続
make update-openapi   # OpenAPI スキーマ再生成
make openapi-viewer   # Swagger UI を http://localhost:9001 で起動
```

### API テスト

```bash
./scripts/test/api-test.sh
```

### フロントエンド型チェック / Lint

```bash
cd front
pnpm svelte-check
pnpm eslint
pnpm lint:style
```

## 開発ガイドライン

詳細な開発ガイドラインは [CLAUDE.md](./CLAUDE.md) を参照してください。

- Entity 層の命名規則
- CSS クラス命名規則 (`layout-` / `style-` / `is-` / `has-`)
- Design Doc 作成フロー (`docs/design-doc/`)
- issue 依存グラフのメンテナンス

## Claude Code 向けの設定

本リポジトリは [Claude Code](https://claude.com/claude-code) を用いた開発を前提に、プロジェクト固有の指示やスキルを `.claude/` 配下に同梱しています。

- `CLAUDE.md` — プロジェクト全体のガイダンス（アーキテクチャ・コーディング規約・テスト方針など）
- `.claude/rules/` — 編集対象ファイルに応じて自動的に読み込まれるルール集
  - `front-component-structure.md` — フロントエンドのファイル構成・CSS 変数規約・Svelte 5 の注意点
  - `front-style-naming.md` — CSS クラス命名規則（`layout-` / `style-` / `is-` / `has-`）
- `.claude/skills/` — リポジトリ固有のワークフローを実行するスキル
  - `make-ddoc` — インタビュー形式で Design Doc を作成する
  - `impl-from-ddoc` — Design Doc を参照して実装し、完了サマリーを追記する
  - `update-issue-dependencies` — issue が close されたとき、依存関係を再評価して `ready-to-start` ラベルを付与する

実装やリファクタリングを依頼する前に `/make-ddoc` で Design Doc を作成し、`/impl-from-ddoc` で実装に進むフローを推奨します。issue を close した・PR がマージされて issue が自動 close されたタイミングでは `/update-issue-dependencies` を必ず実行します。

## ライセンス

MIT License
