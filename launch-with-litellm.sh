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

if [[ -z "${LITELLM_BASE_URL:-}" ]]; then
  echo "Error: LITELLM_BASE_URL is not set (for example, http://localhost:4000)." >&2
  exit 1
fi

if [[ -z "${LITELLM_API_KEY:-}" ]]; then
  echo "Error: LITELLM_API_KEY is not set." >&2
  exit 1
fi

if [[ -z "${LITELLM_MODEL:-}" ]]; then
  echo "Error: LITELLM_MODEL is not set. Use a model_name exposed by your LiteLLM proxy." >&2
  exit 1
fi

export ANTHROPIC_BASE_URL="${LITELLM_BASE_URL%/}"
export ANTHROPIC_AUTH_TOKEN="${LITELLM_API_KEY}"

export ANTHROPIC_DEFAULT_OPUS_MODEL="${LITELLM_OPUS_MODEL:-${LITELLM_MODEL}}"
export ANTHROPIC_DEFAULT_SONNET_MODEL="${LITELLM_SONNET_MODEL:-${LITELLM_MODEL}}"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="${LITELLM_HAIKU_MODEL:-${LITELLM_MODEL}}"

exec claude "$@"
