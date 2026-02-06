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
  echo "ZAI_API_KEY: ${ZAI_API_KEY:+set}${ZAI_API_KEY:-unset}"
  echo "GLM_OPUS_MODEL: ${GLM_OPUS_MODEL:-<default>}"
  echo "GLM_SONNET_MODEL: ${GLM_SONNET_MODEL:-<default>}"
  echo "GLM_HAIKU_MODEL: ${GLM_HAIKU_MODEL:-<default>}"
}

while true; do
  echo ""
  echo "Choose a mode:"
  echo "1) Native Claude"
  echo "2) GLM (glm-4.7 defaults)"
  echo "3) GLM Air (glm-4.5-air defaults)"
  echo "4) Show current env"
  echo "5) Quit"

  read -r -p "Selection [1-5]: " choice

  case "${choice}" in
    1)
      exec claude "$@"
      ;;
    2)
      exec "${SCRIPT_DIR}/launch-with-glm.sh" "$@"
      ;;
    3)
      exec "${SCRIPT_DIR}/launch-with-glm-air.sh" "$@"
      ;;
    4)
      show_env
      ;;
    5)
      exit 0
      ;;
    *)
      echo "Invalid choice."
      ;;
  esac

done
