#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."

echo "==> [1/4] Checking docker availability"
if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: docker is not available"
  exit 1
fi
echo "    docker is available"

echo "==> [2/4] Ensuring middleware (mysql) is running"
if ! docker ps --format '{{.Names}}' | grep -q '^finascope-mysql$'; then
  echo "    finascope-mysql not running, starting compose-dev-middleware.yml"
  docker compose -f compose-dev-middleware.yml up -d
  echo "    waiting for mysql to be ready..."
  sleep 5
else
  echo "    finascope-mysql is already running"
fi

echo "==> [3/4] Ensuring api-test container is running"
if ! docker ps --format '{{.Names}}' | grep -q '^api-test$'; then
  echo "    api-test not running, starting compose-dev-test-api.yml"
  docker compose -f compose-dev-test-api.yml up -d
  echo "    waiting for bundle install to complete..."
  sleep 10
else
  echo "    api-test is already running"
fi

echo "==> [4/4] Running rake test inside api-test container"
docker compose -f compose-dev-test-api.yml exec -T api-test bundle exec rake test
