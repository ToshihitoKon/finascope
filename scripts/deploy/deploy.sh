#!/usr/bin/env bash
# deploy.sh - Deploy finascope to the production server via SSH
#
# Configuration (set via environment variables or .env file):
#   DEPLOY_HOST     - Remote host (e.g. your-gcp-instance.example.com)
#   DEPLOY_USER     - SSH user on the remote host (e.g. deploy)
#   DEPLOY_PATH     - Absolute path on the remote host (e.g. /opt/finascope)
#   DEPLOY_SSH_KEY  - Path to SSH private key (default: ~/.ssh/id_rsa)
#
# NOTE: DB migration requires interactive confirmation and is NOT run automatically.
# To run migrations manually after deploy:
#   ssh -i $DEPLOY_SSH_KEY $DEPLOY_USER@$DEPLOY_HOST \
#     "cd $DEPLOY_PATH/api && bundle exec ruby scripts/create_database.rb"

set -euo pipefail

# ---------------------------------------------------------------------------
# Load configuration
# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [[ -f "${SCRIPT_DIR}/.env" ]]; then
  # shellcheck disable=SC1091
  source "${SCRIPT_DIR}/.env"
fi

DEPLOY_HOST="${DEPLOY_HOST:-}"
DEPLOY_USER="${DEPLOY_USER:-deploy}"
DEPLOY_PATH="${DEPLOY_PATH:-/opt/finascope}"
DEPLOY_SSH_KEY="${DEPLOY_SSH_KEY:-${HOME}/.ssh/id_rsa}"

# ---------------------------------------------------------------------------
# Validate required variables
# ---------------------------------------------------------------------------

if [[ -z "${DEPLOY_HOST}" ]]; then
  echo "ERROR: DEPLOY_HOST is not set."
  echo "  Set it via environment variable or create scripts/deploy/.env"
  exit 1
fi

SSH_OPTS=(-i "${DEPLOY_SSH_KEY}" -o StrictHostKeyChecking=no -o BatchMode=yes)
REMOTE="${DEPLOY_USER}@${DEPLOY_HOST}"

# ---------------------------------------------------------------------------
# Helper functions
# ---------------------------------------------------------------------------

info()  { echo "==> $*"; }
ok()    { echo "    [ok] $*"; }
fail()  { echo "    [FAIL] $*" >&2; exit 1; }

run_remote() {
  ssh "${SSH_OPTS[@]}" "${REMOTE}" "$@"
}

# ---------------------------------------------------------------------------
# Step 1: Verify SSH connectivity
# ---------------------------------------------------------------------------

info "[1/5] Verifying SSH connection to ${REMOTE}"
if ! run_remote "echo connected" >/dev/null 2>&1; then
  fail "Cannot connect to ${REMOTE} with key ${DEPLOY_SSH_KEY}"
fi
ok "SSH connection successful"

# ---------------------------------------------------------------------------
# Step 2: git pull
# ---------------------------------------------------------------------------

info "[2/5] Pulling latest code on remote (${DEPLOY_PATH})"
run_remote "cd ${DEPLOY_PATH} && git pull --ff-only"
ok "git pull complete"

# ---------------------------------------------------------------------------
# Step 3: docker compose build
# ---------------------------------------------------------------------------

info "[3/5] Building Docker images"
run_remote "cd ${DEPLOY_PATH} && docker compose build"
ok "Docker build complete"

# ---------------------------------------------------------------------------
# Step 4: docker compose up -d (rolling restart to minimise downtime)
# ---------------------------------------------------------------------------

info "[4/5] Starting containers (docker compose up -d)"
run_remote "cd ${DEPLOY_PATH} && docker compose up -d --remove-orphans"
ok "Containers started"

# ---------------------------------------------------------------------------
# Step 5: Health check — wait for api container to be healthy/running
# ---------------------------------------------------------------------------

info "[5/5] Waiting for api container to become healthy"

MAX_RETRIES=15
SLEEP_SEC=4
retry=0

while true; do
  status="$(run_remote "docker inspect --format='{{.State.Status}}' api 2>/dev/null || echo missing")"

  if [[ "${status}" == "running" ]]; then
    # If the container defines a healthcheck, also verify it passes
    health="$(run_remote "docker inspect --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' api 2>/dev/null || echo none")"
    if [[ "${health}" == "healthy" || "${health}" == "none" ]]; then
      ok "api container is ${status} (health: ${health})"
      break
    fi
  fi

  retry=$(( retry + 1 ))
  if (( retry >= MAX_RETRIES )); then
    fail "api container did not become healthy within $(( MAX_RETRIES * SLEEP_SEC )) seconds (status=${status})"
  fi

  echo "    waiting... (${retry}/${MAX_RETRIES}, status=${status})"
  sleep "${SLEEP_SEC}"
done

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------

echo ""
echo "Deploy complete."
echo ""
echo "NOTE: DB migration was NOT run automatically (it requires interactive confirmation)."
echo "To run migrations manually:"
echo "  ssh -i ${DEPLOY_SSH_KEY} ${REMOTE} \\"
echo "    \"cd ${DEPLOY_PATH}/api && bundle exec ruby scripts/create_database.rb\""
