#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR="${HOME}/.claude/glm-switcher"

mkdir -p "${DEST_DIR}"

cp -f "${ROOT_DIR}/launch-with-glm.sh" "${DEST_DIR}/"
cp -f "${ROOT_DIR}/launch-with-glm-air.sh" "${DEST_DIR}/"
cp -f "${ROOT_DIR}/claude-code-glm-switcher.sh" "${DEST_DIR}/"

chmod +x "${DEST_DIR}/launch-with-glm.sh" \
  "${DEST_DIR}/launch-with-glm-air.sh" \
  "${DEST_DIR}/claude-code-glm-switcher.sh"

BLOCK_START="# >>> glm-switcher >>>"
BLOCK_END="# <<< glm-switcher <<<"
BLOCK_CONTENT="${BLOCK_START}
# GLM switcher aliases
alias claude-glm=\"${DEST_DIR}/launch-with-glm.sh\"
alias claude-glm-air=\"${DEST_DIR}/launch-with-glm-air.sh\"
alias claude-switch=\"${DEST_DIR}/claude-code-glm-switcher.sh\"
${BLOCK_END}"

add_block_if_missing() {
  local file="$1"
  if [[ ! -f "${file}" ]]; then
    touch "${file}"
  fi
  if ! grep -q "${BLOCK_START}" "${file}"; then
    printf "\n%s\n" "${BLOCK_CONTENT}" >> "${file}"
  fi
}

detect_shell() {
  local shell_name
  shell_name="$(basename "${SHELL:-}")"
  if [[ "${shell_name}" == "zsh" ]]; then
    echo "zsh"
    return
  fi
  if [[ "${shell_name}" == "bash" ]]; then
    echo "bash"
    return
  fi
  echo "zsh"
}

choose_shell() {
  local detected="$1"
  if [[ -t 0 ]]; then
    echo "Detected shell: ${detected}"
    echo "Which shell config should be updated?"
    echo "1) ${detected} (recommended)"
    echo "2) bash"
    echo "3) zsh"
    echo "4) both"
    read -r -p "Selection [1-4]: " choice
    case "${choice}" in
      2) echo "bash" ;;
      3) echo "zsh" ;;
      4) echo "both" ;;
      *) echo "${detected}" ;;
    esac
  else
    echo "${detected}"
  fi
}

detected_shell="$(detect_shell)"
selection="$(choose_shell "${detected_shell}")"

shell_files=()
case "${selection}" in
  zsh)
    shell_files=("${HOME}/.zshrc")
    ;;
  bash)
    shell_files=("${HOME}/.bashrc" "${HOME}/.bash_profile")
    ;;
  both)
    shell_files=("${HOME}/.zshrc" "${HOME}/.bashrc" "${HOME}/.bash_profile")
    ;;
  *)
    shell_files=("${HOME}/.zshrc")
    ;;
esac

added=0
for f in "${shell_files[@]}"; do
  if [[ -f "${f}" ]]; then
    add_block_if_missing "${f}"
    added=1
  fi
done

if [[ "${added}" -eq 0 ]]; then
  for f in "${shell_files[@]}"; do
    add_block_if_missing "${f}"
  done
fi

echo "Installed to ${DEST_DIR}"
case "${selection}" in
  bash)
    echo "Restart your shell or run: source ~/.bashrc"
    ;;
  both)
    echo "Restart your shell or run: source ~/.zshrc or source ~/.bashrc"
    ;;
  *)
    echo "Restart your shell or run: source ~/.zshrc"
    ;;
esac
