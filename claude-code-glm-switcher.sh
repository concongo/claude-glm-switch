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

show_env() {
  if [[ -n "${ZAI_API_KEY:-}" ]]; then
    local key_tail
    key_tail="${ZAI_API_KEY: -4}"
    echo "ZAI_API_KEY: ****${key_tail}"
  else
    echo "ZAI_API_KEY: unset"
  fi
  echo "GLM_OPUS_MODEL: ${GLM_OPUS_MODEL:-<default>}"
  echo "GLM_SONNET_MODEL: ${GLM_SONNET_MODEL:-<default>}"
  echo "GLM_HAIKU_MODEL: ${GLM_HAIKU_MODEL:-<default>}"
  echo "LITELLM_BASE_URL: ${LITELLM_BASE_URL:-unset}"
  if [[ -n "${LITELLM_API_KEY:-}" ]]; then
    echo "LITELLM_API_KEY: set"
  else
    echo "LITELLM_API_KEY: unset"
  fi
  echo "LITELLM_MODEL: ${LITELLM_MODEL:-unset}"
  echo "LITELLM_OPUS_MODEL: ${LITELLM_OPUS_MODEL:-<default>}"
  echo "LITELLM_SONNET_MODEL: ${LITELLM_SONNET_MODEL:-<default>}"
  echo "LITELLM_HAIKU_MODEL: ${LITELLM_HAIKU_MODEL:-<default>}"
}

while true; do
  echo ""
  echo "Choose a mode:"
  echo "1) Native Claude"
  echo "2) GLM 5.3"
  echo "3) GLM 5.3 Flash"
  echo "4) LiteLLM proxy"
  echo "5) Show current env"
  echo "6) Quit"

  read -r -p "Selection [1-6]: " choice

  case "${choice}" in
    1)
      exec claude "$@"
      ;;
    2)
      exec "${SCRIPT_DIR}/launch-with-glm.sh" "$@"
      ;;
    3)
      exec "${SCRIPT_DIR}/launch-with-glm-53-flash.sh" "$@"
      ;;
    4)
      exec "${SCRIPT_DIR}/launch-with-litellm.sh" "$@"
      ;;
    5)
      show_env
      ;;
    6)
      exit 0
      ;;
    *)
      echo "Invalid choice."
      ;;
  esac

done
