.PHONY: help dev-middleware dev-front dev-api logs-front logs-api clean schema-update console api-shell db-shell update-openapi openapi-viewer

help:
	@cat Makefile | grep '^[a-zA-Z_-]\+:' | sed 's/://g' | awk '{printf " - %s\n", $$1}'

dev-middleware:
	docker compose -f compose-dev-middleware.yml up -d --build

dev-front:
	docker compose -f compose-dev-front.yml up -d --build

dev-api:
	docker compose -f compose-dev-api.yml up -d --build

logs-front:
	docker compose -f compose-dev-front.yml logs -f

logs-api:
	docker compose -f compose-dev-api.yml logs -f

logs:
	docker compose -f compose-dev-middleware.yml -f compose-dev-front.yml -f compose-dev-api.yml logs -f

clean:
	docker compose -f compose-dev-middleware.yml -f compose-dev-front.yml -f compose-dev-api.yml down

schema-update:
	@echo "updating schema..."
	docker compose -f compose-dev-api.yml exec api bash -c "cd /app && bundle exec ruby scripts/create_database.rb"
	@echo "schema updated"

console:
	docker compose -f compose-dev-api.yml exec api bash -c "cd /app && bundle exec ruby scripts/finascope-console.rb"

# シェルアクセス
api-shell:
	docker compose -f compose-dev-api.yml exec api bash

db-shell:
	docker compose -f compose-dev-middleware.yml exec mysql mysql -u finascope -pfinascope finascope_dev

# OpenAPI
update-openapi:
	docker run -it --rm -v `pwd`:/app ruby:3.4 bash -c "cd /app/api && bundle i && rake openapi:generate"

openapi-viewer:
	@echo "Access to http://localhost:9001 to view the OpenAPI documentation\n\n"
	docker run -p 9001:8080 -v `pwd`/docs/openapi_swagger_doc.json:/openapi.json -e SWAGGER_JSON=/openapi.json docker.swagger.io/swaggerapi/swagger-ui
