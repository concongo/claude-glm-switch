#!/usr/bin/env bash
set -euo pipefail

DEST_DIR="${HOME}/.claude/glm-switcher"

BLOCK_START="# >>> glm-switcher >>>"
BLOCK_END="# <<< glm-switcher <<<"

remove_block() {
  local file="$1"
  [[ -f "${file}" ]] || return 0
  perl -0pi -e "s/\n?${BLOCK_START}.*?${BLOCK_END}\n?//s" "${file}"
}

shell_files=("${HOME}/.zshrc" "${HOME}/.bashrc" "${HOME}/.bash_profile")
for f in "${shell_files[@]}"; do
  remove_block "${f}"
done

if [[ -d "${DEST_DIR}" ]]; then
  rm -rf "${DEST_DIR}"
fi

echo "Uninstalled glm-switcher"
