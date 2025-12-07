# Finascope開発用Makefile

.PHONY: help dev dev-mysql logs schema-update console api-shell db-shell clean update-openapi openapi-viewer

# デフォルトターゲット
help:
	@cat Makefile | grep '^[a-zA-Z_-]\+:' | sed 's/://g' | awk '{printf " - %s\n", $$1}'

# 開発環境管理
dev:
	docker compose -f compose-dev.yml up -d

dev-mysql:
	docker compose -f compose-dev-mysql.yml up -d

logs:
	docker compose -f compose-dev.yml logs -f

clean:
	docker compose -f compose-dev.yml -f compose-dev-mysql.yml down

# データベース操作
schema-update:
	@echo "🔄 データベーススキーマを更新中..."
	docker compose -f compose-dev.yml exec api bash -c "cd /app && bundle exec ruby scripts/create_database.rb"
	@echo "✅ スキーマ更新完了"

console:
	docker compose -f compose-dev.yml exec api bash -c "cd /app && bundle exec ruby scripts/finascope-console.rb"

# シェルアクセス
api-shell:
	docker compose -f compose-dev.yml exec api bash

db-shell:
	docker compose -f compose-dev.yml exec mysql mysql -u finascope -pfinascope finascope_dev

# OpenAPI
update-openapi:
	docker run -it --rm -v `pwd`:/app ruby:3.4 bash -c "cd /app/api && bundle i && rake openapi:generate"

openapi-viewer:
	@echo "Access to http://localhost:9001 to view the OpenAPI documentation\n\n"
	docker run -p 9001:8080 -v `pwd`/docs/openapi_swagger_doc.json:/openapi.json -e SWAGGER_JSON=/openapi.json docker.swagger.io/swaggerapi/swagger-ui
