#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

load_env() {
  if [[ -f ".env" ]]; then
    set -a
    # shellcheck disable=SC1091
    source ".env"
    set +a
    return
  fi

  local env_file="${SCRIPT_DIR}/.env"
  if [[ -f "${env_file}" ]]; then
    set -a
    # shellcheck disable=SC1090
    source "${env_file}"
    set +a
  fi
}

load_env

if ! command -v claude >/dev/null 2>&1; then
  echo "Error: 'claude' is not on PATH. Install Claude Code first." >&2
  exit 1
fi

if [[ -z "${ZAI_API_KEY:-}" ]]; then
  echo "Error: ZAI_API_KEY is not set." >&2
  echo "Set it in your shell profile, e.g.: export ZAI_API_KEY=YOUR_KEY_HERE" >&2
  exit 1
fi

export ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic"
export ANTHROPIC_AUTH_TOKEN="${ZAI_API_KEY}"

export ANTHROPIC_DEFAULT_OPUS_MODEL="${GLM_OPUS_MODEL:-glm-4.5-air}"
export ANTHROPIC_DEFAULT_SONNET_MODEL="${GLM_SONNET_MODEL:-glm-4.5-air}"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="${GLM_HAIKU_MODEL:-glm-4.5-air}"

exec claude "$@"
