# Finascope開発用Makefile

.PHONY: help dev dev-mysql logs schema-update console api-shell db-shell clean

# デフォルトターゲット
help:
	@echo "Finascope開発用コマンド:"
	@echo "  make dev           開発環境を起動 (compose-dev.yml)"
	@echo "  make dev-mysql     共有MySQL環境を起動 (compose-dev-mysql.yml)"
	@echo "  make logs          コンテナログを表示"
	@echo "  make schema-update DBスキーマを更新"
	@echo "  make console       APIコンソールを起動"
	@echo "  make api-shell     APIコンテナのシェルに接続"
	@echo "  make db-shell      MySQLシェルに接続"
	@echo "  make clean         開発環境を停止・削除"

# 開発環境管理
dev:
	docker compose -f compose-dev.yml up -d

dev-mysql:
	docker compose -f compose-dev-mysql.yml up -d

logs:
	docker compose logs -f

clean:
	docker compose -f compose-dev.yml down
	docker compose -f compose-dev-mysql.yml down

# データベース操作
schema-update:
	@echo "🔄 データベーススキーマを更新中..."
	docker compose exec api bash -c "cd /app && bundle exec ruby scripts/create_database.rb"
	@echo "✅ スキーマ更新完了"

console:
	docker compose exec api bash -c "cd /app && bundle exec ruby scripts/finascope-console.rb"

# シェルアクセス
api-shell:
	docker compose exec api bash

db-shell:
	docker compose exec mysql mysql -u finascope -pfinascope finascope_dev
