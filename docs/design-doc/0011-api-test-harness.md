# 0011 api テストハーネス整備

> **scope**: api | **date**: 2026-05-04

## 概要

`api/` 配下のリファクタリングを安全に進めるための土台として、RSpec + rack-test による API E2E テストハーネスを整備する。テスト実行は Docker コンテナ内で完結させ、`compose-dev-middleware.yml` の MySQL を再利用する。初回スコープは golden path の数パターンに留め、以後のリファクタリングと並行して拡充していく。

## 背景

現在 `api/` にはテストが存在しない（`spec/` `test/` ディレクトリなし、テスト FW の gem も未導入）。GitHub issue #34-56 でリファクタリング・バグ修正・セキュリティ改善の方針が立っており、これらの作業に着手する前に「内部実装を変えても外部仕様が壊れていない」ことを担保する仕組みが必要。

ハーネスの方針は事前に以下の通り合意済み:
- テスト FW: **RSpec**
- テスト DB: **MySQL**（既存 `compose-dev-middleware.yml` の MySQL を流用）
- 初回スコープ: **API E2E の数パターンのみ**、以後のタスクで拡充
- 認証: **`Firebase.decode_jwt` をスタブする helper を最初から導入**（`EXAMPLE_USER_UID` 素通しに依存しない）
- 実行環境: **Docker コンテナ内で完結**（ホスト側 Ruby 環境への依存を作らない）
- bundle_cache: **api コンテナと共有**（環境統一のため）。ただし問題発生時に切り戻せるよう独立タスクとして検証する
- 実行スクリプト: `[repo-root]/scripts/test/` 配下に置き、AI Agent が出力を読んで状況を把握しやすい構成にする

## 目標

- `api/` 配下のリファクタリング時に「外部仕様が壊れていないこと」を自動的に検証できる
- AI Agent が単一コマンドでテスト実行できる（compose の起動順序などを意識せずに済む）
- AI Agent がテスト失敗時の出力を読んで原因を特定できる（明示的なログ・ステータス出力）
- Firebase JWT 検証ロジックの将来の変更に追従できるよう、認証はスタブ経由で扱う
- テスト DB はアプリ DB（`finascope`）と分離し、データ汚染が起きない（テスト DB 名: `finascope_test`）
- 初回 spec で以下の golden path をカバーする:
  - `GET /api/healthcheck`
  - `GET /api/v1/categories`（空配列）
  - `POST /api/v1/categories` → `GET /api/v1/categories`（作成と一覧）
  - `PUT /api/v1/categories/:id`（更新）
  - `POST /api/v1/records` → `GET /api/v1/records`（作成と一覧）

## 非目標

- 全エンドポイント・全分岐の網羅（次回以降のタスクで拡充）
- Service / Repository / Lib 層の単体テスト（リファクタで責務が動く可能性が高く脆いため、まずは E2E のみ）
- バリデーションエラー・認可エラー等の異常系（次回以降）
- CI 連携（GitHub Actions ワークフロー追加など）。本タスクではローカル実行のみ
- パフォーマンステスト・負荷テスト
- Firebase JWT の本物の検証フロー（スタブで代替）

## 設計

### 全体構成

```
[host]
  └─ scripts/test/api-test.sh  ← Claude Code / 開発者はこれを叩く
       │
       ├─ docker compose -f compose-dev-middleware.yml up -d  (mysql)
       ├─ docker compose -f compose-dev-test-api.yml up -d    (api-test container)
       └─ docker compose -f compose-dev-test-api.yml exec api-test bundle exec rake test

[docker network: finascope-net]
  ├─ finascope-mysql  ← 既存 (compose-dev-middleware.yml)
  └─ api-test         ← 新規 (compose-dev-test-api.yml)
       │
       └─ bundle exec rake test
            ├─ test:prepare_db  (CREATE DATABASE finascope_test IF NOT EXISTS)
            └─ test:rspec       (bundle exec rspec)
```

### Docker 構成

**新規ファイル: `compose-dev-test-api.yml`**

`api` 用テストコンテナであることをファイル名で明示する。常駐させて `docker compose exec` で rspec を叩く形式。

```yaml
services:
  api-test:
    container_name: api-test
    build:
      context: ./api
      dockerfile: Dockerfile
    command: ["sh", "-c", "bundle install && tail -f /dev/null"]
    volumes:
      - ./api:/app
      - bundle_cache:/var/bundle_cache  # api コンテナと共有
    environment:
      - BUNDLE_PATH=/var/bundle_cache
      - DB_HOST=finascope-mysql
      - DB_PORT=3306
      - DB_USER=finascope_app
      - DB_PASSWORD=finascope_app_password
      - DB_NAME=finascope_test
      - RACK_ENV=test
    networks:
      - finascope-net

volumes:
  bundle_cache:
    external: true
    name: finascope_bundle_cache  # 既存 api コンテナと共有

networks:
  finascope-net:
    external: true
    name: finascope-net
```

**bundle_cache 共有方針:**
- `api` コンテナ（compose-dev-api.yml）と `api-test` コンテナで bundle_cache ボリュームを共有する
- 理由: gem インストール時間の短縮、環境差異の最小化
- リスク: 片方で `bundle install` したものがもう片方で frozen 違反になる可能性
- 緩和策: 実装ステップ 4 で「共有版」、ステップ 5 で「動作検証」、問題があればステップ 5b で「分離版へ切り戻し」を独立タスクとして分けて進める

### テスト DB 戦略

- DB 名: `finascope_test`
- 作成: 既存 MySQL ボリュームに対しては `mysql/init.d/` の SQL は再実行されないため、`rake test:prepare_db` で `CREATE DATABASE IF NOT EXISTS` を流す（毎回実行しても冪等）
- スキーマ: `db/models.rb` の `RECORD_MODELS.each` を回し、`ActiveRecord::Schema.define` で `force: true` 再作成（テストコンテナ起動時 1 回）
- データクリア: `database_cleaner-active_record` の `:truncation` 戦略を使い、各 example の前後でテーブルクリア

新規 SQL も追加するが、既存環境向けには `prepare_db` タスクの SQL が機能する。

**新規ファイル: `mysql/init.d/01_test_database.sql`**

```sql
CREATE DATABASE IF NOT EXISTS finascope_test;
GRANT ALL PRIVILEGES ON finascope_test.* TO 'finascope_app'@'%';
FLUSH PRIVILEGES;
```

新規環境向け（mysql ボリュームを最初から作り直す場合）の保険として。

### 認証スタブ戦略

`api/app/api/root.rb` の `request_userdata` は Authorization ヘッダーが空なら `Constants::EXAMPLE_USER_UID` を返す素通し動作になっている（issue #34 で塞ぐ予定）。

spec ではこの素通しに依存せず、`Firebase.decode_jwt` を RSpec の `allow(...).to receive(...)` でスタブして固定 uid を返させる。`stub_authenticated_user` ヘルパー経由で利用する。

これにより、issue #34 で素通し動作を消しても spec はそのまま動く。

### Rakefile 拡張

既存の `api/Rakefile` に test タスクを追加する。

```ruby
namespace :test do
  desc "Create test database if not exists (idempotent)"
  task :prepare_db do
    require_relative "envs"
    cmd = %(mysql -h #{Envs::DB_HOST} -P #{Envs::DB_PORT} -u root -pexample) +
          %( -e "CREATE DATABASE IF NOT EXISTS finascope_test;) +
          %( GRANT ALL PRIVILEGES ON finascope_test.* TO 'finascope_app'@'%';) +
          %( FLUSH PRIVILEGES;")
    sh cmd
  end

  desc "Run rspec"
  task :rspec do
    sh "bundle exec rspec"
  end
end

desc "Prepare DB and run rspec (assumes running inside api-test container)"
task test: ["test:prepare_db", "test:rspec"]
```

mysql クライアントは `ruby:3.4-bookworm` イメージに含まれていない可能性があるため、Dockerfile で `default-mysql-client` をインストールする必要がある（実装ステップで対応）。

### spec ディレクトリ構成

```
api/
├── .rspec                              # 新規
├── spec/
│   ├── spec_helper.rb                  # 新規
│   ├── support/
│   │   ├── api_helper.rb               # 新規 (Rack::Test::Methods)
│   │   ├── auth_stub.rb                # 新規 (Firebase.decode_jwt スタブ)
│   │   └── schema_loader.rb            # 新規 (起動時にテーブル再作成)
│   └── api/
│       └── v1/
│           ├── healthcheck_spec.rb     # 新規
│           ├── categories_spec.rb      # 新規
│           └── records_spec.rb         # 新規
```

#### spec_helper.rb の責務

1. `$LOAD_PATH.unshift` でアプリのロードパス確保（config.ru と同等）
2. `app/api/root` `db/connection` `lib/firebase` を require
3. `DB::Connection.establish` で `finascope_test` に接続
4. `SchemaLoader.load!` で全テーブル force 再作成
5. `support/*` を全部 require
6. RSpec.configure:
   - `include ApiHelper`
   - `include AuthStub`
   - `before(:suite)` で DatabaseCleaner.clean_with(:truncation)
   - `before(:each)` で DatabaseCleaner.start, `after(:each)` で DatabaseCleaner.clean

#### support/api_helper.rb

```ruby
require "rack/test"

module ApiHelper
  include Rack::Test::Methods

  def app
    API::Root
  end

  def json_body
    JSON.parse(last_response.body, symbolize_names: true)
  end
end
```

#### support/auth_stub.rb

```ruby
module AuthStub
  TEST_UID = "test_user_uid_001"

  def stub_authenticated_user(uid: TEST_UID)
    allow(Firebase).to receive(:decode_jwt).and_return(
      uid: uid, name: "Test User", picture_url: nil
    )
  end

  def auth_header(uid: TEST_UID)
    { "HTTP_AUTHORIZATION" => "Bearer dummy.jwt.token" }
  end
end
```

#### support/schema_loader.rb

`scripts/create_database.rb` の対話的部分を取り除き、毎回 `force: true` で全テーブル作り直すユーティリティ。

```ruby
require "active_record"
require "db/models"

module SchemaLoader
  def self.load!
    ActiveRecord::Schema.define do
      DB::Model::RECORD_MODELS.each do |model_class|
        create_table model_class.table_name, id: false, force: true do |t|
          model_class.define_table_schema(t)
        end
      end
    end
  end
end
```

### 初回 spec の内容

#### healthcheck_spec.rb

```ruby
RSpec.describe "GET /api/healthcheck" do
  it "returns healthy" do
    get "/api/healthcheck"
    expect(last_response.status).to eq(200)
    expect(json_body).to eq(status: "healthy")
  end
end
```

#### categories_spec.rb

```ruby
RSpec.describe "Categories API" do
  before { stub_authenticated_user }

  describe "GET /api/v1/categories" do
    it "returns empty list initially" do
      get "/api/v1/categories", {}, auth_header
      expect(last_response.status).to eq(200)
      expect(json_body[:categories]).to eq([])
    end
  end

  describe "POST /api/v1/categories" do
    it "creates a category and returns it in the list" do
      post "/api/v1/categories", { label: "Food" }, auth_header
      expect(last_response.status).to eq(201).or eq(200)
      created_id = json_body[:id]
      expect(created_id).to be_a(String)

      get "/api/v1/categories", {}, auth_header
      labels = json_body[:categories].map { |c| c[:label] }
      expect(labels).to include("Food")
    end
  end

  describe "PUT /api/v1/categories/:id" do
    it "updates the label of an existing category" do
      post "/api/v1/categories", { label: "Old" }, auth_header
      id = json_body[:id]

      put "/api/v1/categories/#{id}", { id: id, label: "New" }, auth_header
      expect(last_response.status).to eq(200)

      get "/api/v1/categories", {}, auth_header
      labels = json_body[:categories].map { |c| c[:label] }
      expect(labels).to include("New")
      expect(labels).not_to include("Old")
    end
  end
end
```

#### records_spec.rb

`POST /api/v1/records` のシグネチャを `app/api/v1/records.rb` で確認のうえ実装。`record_type_id` `state_id` `title` `amount` `category_id` `payment_method_id` `date` などの必須項目を投入する想定。前提として category と payment_method の作成が必要。

### 実行スクリプト

**新規ファイル: `scripts/test/api-test.sh`**

AI Agent が出力を見て状況を把握できるよう、各ステップで明示的にログを出す。

```bash
#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."

echo "==> [1/4] Checking docker availability"
if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: docker is not available"
  exit 1
fi

echo "==> [2/4] Ensuring middleware (mysql) is running"
if ! docker ps --format '{{.Names}}' | grep -q '^finascope-mysql$'; then
  echo "    finascope-mysql not running, starting compose-dev-middleware.yml"
  docker compose -f compose-dev-middleware.yml up -d
else
  echo "    finascope-mysql is already running"
fi

echo "==> [3/4] Ensuring api-test container is running"
if ! docker ps --format '{{.Names}}' | grep -q '^api-test$'; then
  echo "    api-test not running, starting compose-dev-test-api.yml"
  docker compose -f compose-dev-test-api.yml up -d
  echo "    waiting for bundle install..."
  # bundle install が終わるまで簡易的に待つ
  sleep 5
else
  echo "    api-test is already running"
fi

echo "==> [4/4] Running rake test inside api-test container"
docker compose -f compose-dev-test-api.yml exec -T api-test bundle exec rake test
```

実行権限を付与する: `chmod +x scripts/test/api-test.sh`

### Dockerfile への追加

`api/Dockerfile` に mysql クライアントをインストールする行を追加する（`rake test:prepare_db` から `mysql` コマンドを叩くため）。

```dockerfile
FROM ruby:3.4-bookworm
RUN apt-get update && apt-get install -y --no-install-recommends default-mysql-client \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
```

## 変更ファイル一覧

新規追加と既存変更を分けて記載する。

**新規追加:**

- `compose-dev-test-api.yml` — api-test コンテナ定義（finascope-net 接続、bundle_cache 共有、test DB 名指定）
- `mysql/init.d/01_test_database.sql` — 新規環境向けの test DB 作成 SQL
- `scripts/test/api-test.sh` — ホスト側から叩くテスト実行スクリプト（compose の起動状況を確認しつつ rake test を実行）
- `api/.rspec` — `--require spec_helper`, `--format documentation`, `--color`
- `api/spec/spec_helper.rb` — RSpec 設定、DB 接続、SchemaLoader 起動、DatabaseCleaner 設定
- `api/spec/support/api_helper.rb` — `Rack::Test::Methods` を include したヘルパー
- `api/spec/support/auth_stub.rb` — `Firebase.decode_jwt` スタブヘルパー
- `api/spec/support/schema_loader.rb` — テスト起動時に全テーブルを force 再作成するユーティリティ
- `api/spec/api/v1/healthcheck_spec.rb` — ヘルスチェック spec
- `api/spec/api/v1/categories_spec.rb` — Categories の GET/POST/PUT spec
- `api/spec/api/v1/records_spec.rb` — Records の POST/GET spec

**既存変更:**

- `api/Gemfile` — test グループに `rspec`, `rack-test`, `database_cleaner-active_record` を追加
- `api/Gemfile.lock` — `bundle install` で更新
- `api/Rakefile` — `test:prepare_db`, `test:rspec`, トップレベル `test` タスクを追加
- `api/Dockerfile` — `default-mysql-client` インストールを追加

## 実装ステップ

各ステップは独立したコミットに分けて、問題発生時に二分探索しやすくする。

### ステップ 1: Gemfile に test gem を追加

- `api/Gemfile` の test グループに gem 追加
- ホスト側で `bundle install` できないので、後続のステップで Docker 内で更新する
- このステップでは Gemfile のみ変更し commit

### ステップ 2: Dockerfile に mysql クライアントを追加

- `api/Dockerfile` を更新
- 既存 api コンテナをリビルドしても動作することを確認

### ステップ 3: テスト用 compose と SQL の追加

- `compose-dev-test-api.yml` 新規作成
- `mysql/init.d/01_test_database.sql` 新規作成
- まだ bundle_cache の共有設定は仮のものでよい

### ステップ 4: bundle_cache 共有での api-test コンテナ起動検証

**この検証ステップを独立コミットとし、問題が出れば次の 5b でロールバックできるようにする。**

- `compose-dev-middleware.yml` を起動
- `compose-dev-test-api.yml` を起動して bundle install が成功することを確認
- 既存の api コンテナ（compose-dev-api.yml）も並行で起動し、両方が同じ bundle_cache を読んで動作することを確認
- 確認できたら次のステップへ

### ステップ 5a: bundle_cache 共有が動作する場合 → そのまま続行

- 何もしない

### ステップ 5b: bundle_cache 共有で問題が出た場合 → 分離版へ切り戻し

- `compose-dev-test-api.yml` の `bundle_cache` ボリュームを test 専用 (`finascope_bundle_cache_test`) に変更
- 共有を諦めた理由を design doc の「未解決事項」に追記
- ステップ 4 のコミットを直接 revert するのではなく、追加の修正コミットとして対応する

### ステップ 6: spec_helper.rb と support/* の作成

- `api/.rspec`
- `api/spec/spec_helper.rb`
- `api/spec/support/schema_loader.rb`
- `api/spec/support/api_helper.rb`
- `api/spec/support/auth_stub.rb`

### ステップ 7: Rakefile に test タスク追加

- `api/Rakefile` を更新
- `docker compose exec api-test bundle exec rake test:prepare_db` 単体で動作することを確認

### ステップ 8: 初回 spec ファイル作成

順番に動作確認する（先のものが動かないと後のものも動かないため）。

1. `api/spec/api/v1/healthcheck_spec.rb` 作成、実行して通すことを確認
2. `api/spec/api/v1/categories_spec.rb` 作成、実行して通すことを確認
3. `api/spec/api/v1/records_spec.rb` 作成、実行して通すことを確認

### ステップ 9: ホスト実行用スクリプト作成

- `scripts/test/api-test.sh` 作成
- `chmod +x` で実行権限付与
- ホストから `./scripts/test/api-test.sh` を叩いて E2E が通ることを確認

### ステップ 10: ドキュメント整備

- 本 design doc に実装サマリを追記
- `CLAUDE.md` の「型チェック」「Lint チェック」と並ぶセクションとして「テスト実行」を追加
  - 実行コマンド: `./scripts/test/api-test.sh`
  - 前提: docker compose の middleware が利用可能であること

## 代替案

### A. ホスト側 Ruby で rspec を直接実行

- 採用しない理由: ホスト側の Ruby バージョン管理・MySQL 接続のための port 公開が追加で必要。動作確認環境とテスト環境を一致させたいというユーザーの意向に反する。

### B. compose-dev-api.yml に test コンテナを追記

- 採用しない理由: 「api テスト用」であることがファイル名から分かりにくい。テスト時のみ立ち上げる運用ができず、開発時のオーバヘッドが増える。

### C. bundle_cache を最初から分離

- 採用しない理由: 環境統一を最初から意識しておきたいというユーザーの意向。ただし問題発生時に切り戻せるよう、検証を独立ステップとして用意した。

### D. テスト DB クリア戦略を transaction rollback にする

- 採用しない理由: Grape API は通常リクエスト単位で transaction を切るため、`Rack::Test` 経由の請求と spec の transaction が干渉する可能性がある。`:truncation` の方が予測可能。速度差はテーブル数が少ないので無視できる。

### E. Service / Repository の単体テストも初回で書く

- 採用しない理由: リファクタで層構成自体が変わる可能性があり、テストごと書き直しになるリスク。E2E のみで内部リファクタの安全網としては機能する。

## 未解決事項

- bundle_cache 共有で frozen 違反などの問題が出た場合の対処（実装ステップ 5b で切り戻しを準備しているが、頻発するなら本番運用時の方針を再検討する必要あり）
- `POST /api/v1/records` の必須パラメータの正確なリスト（`app/api/v1/records.rb` を実装時に確認する）
- 将来的に CI でこのテストを回す方針（GitHub Actions で MySQL service container を起動して同等のテストを動かすか、まったく別構成にするか）— 本タスクでは扱わない
