#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR="${HOME}/.claude/glm-switcher"

mkdir -p "${DEST_DIR}"

cp -f "${ROOT_DIR}/launch-with-glm.sh" "${DEST_DIR}/"
cp -f "${ROOT_DIR}/launch-with-glm-air.sh" "${DEST_DIR}/"
cp -f "${ROOT_DIR}/launch-with-glm-5.sh" "${DEST_DIR}/"
cp -f "${ROOT_DIR}/launch-with-glm-51.sh" "${DEST_DIR}/"
cp -f "${ROOT_DIR}/launch-with-glm-5-turbo.sh" "${DEST_DIR}/"
cp -f "${ROOT_DIR}/claude-code-glm-switcher.sh" "${DEST_DIR}/"

chmod +x "${DEST_DIR}/launch-with-glm.sh" \
  "${DEST_DIR}/launch-with-glm-air.sh" \
  "${DEST_DIR}/launch-with-glm-5.sh" \
  "${DEST_DIR}/launch-with-glm-51.sh" \
  "${DEST_DIR}/launch-with-glm-5-turbo.sh" \
  "${DEST_DIR}/claude-code-glm-switcher.sh"

BLOCK_START="# >>> glm-switcher >>>"
BLOCK_END="# <<< glm-switcher <<<"

prompt_for_api_key() {
  local api_key="${ZAI_API_KEY:-}"

  if [[ ! -t 0 ]]; then
    printf "%s" "${api_key}"
    return
  fi

  if [[ -n "${api_key}" ]]; then
    printf "%s\n" "ZAI_API_KEY is already set in your current shell." >&2
    read -r -p "Save the current key to your shell config? [Y/n]: " save_current < /dev/tty
    case "${save_current}" in
      n|N)
        printf "%s" ""
        return
        ;;
      *)
        printf "%s" "${api_key}"
        return
        ;;
    esac
  fi

  printf "%s" "Enter your Z.AI API key to save it in your shell config (leave blank to skip): " >&2
  read -r -s api_key < /dev/tty
  printf "\n" >&2
  printf "%s" "${api_key}"
}

build_block_content() {
  cat <<EOF
${BLOCK_START}
# GLM switcher aliases
alias claude-glm="${DEST_DIR}/launch-with-glm.sh"
alias claude-glm-air="${DEST_DIR}/launch-with-glm-air.sh"
alias claude-glm-5="${DEST_DIR}/launch-with-glm-5.sh"
alias claude-glm-51="${DEST_DIR}/launch-with-glm-51.sh"
alias claude-glm-5-turbo="${DEST_DIR}/launch-with-glm-5-turbo.sh"
alias claude-switch="${DEST_DIR}/claude-code-glm-switcher.sh"
${BLOCK_END}
EOF
}

set_api_key_in_shell_file() {
  local file="$1"
  local api_key="$2"

  [[ -n "${api_key}" ]] || return 0
  [[ -f "${file}" ]] || touch "${file}"

  python3 - <<'PY' "${file}" "${api_key}"
import pathlib
import re
import sys

path = pathlib.Path(sys.argv[1])
api_key = sys.argv[2]
text = path.read_text() if path.exists() else ""
line = f'export ZAI_API_KEY="{api_key}"'
pattern = re.compile(r'^[ \t]*export[ \t]+ZAI_API_KEY=.*$', re.M)

if pattern.search(text):
    new_text = pattern.sub(line, text, count=1)
else:
    if text and not text.endswith("\n"):
        text += "\n"
    new_text = text + line + "\n"

path.write_text(new_text)
PY
}

upsert_block() {
  local file="$1"
  local block_content="$2"
  if [[ ! -f "${file}" ]]; then
    touch "${file}"
  fi
  if grep -Fq "${BLOCK_START}" "${file}"; then
    python3 - <<'PY' "${file}" "${BLOCK_START}" "${BLOCK_END}" "${block_content}"
import pathlib
import re
import sys

path = pathlib.Path(sys.argv[1])
start = sys.argv[2]
end = sys.argv[3]
block = sys.argv[4]
text = path.read_text()
pattern = re.compile(r"\n?" + re.escape(start) + r".*?" + re.escape(end) + r"\n?", re.S)
new_text, count = pattern.subn("\n" + block + "\n", text, count=1)
if count == 0:
    if text and not text.endswith("\n"):
        text += "\n"
    new_text = text + "\n" + block + "\n"
path.write_text(new_text)
PY
  else
    printf "\n%s\n" "${block_content}" >> "${file}"
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
    printf "%s\n" "Detected shell: ${detected}" >&2
    printf "%s\n" "Which shell config should be updated?" >&2
    printf "%s\n" "1) ${detected} (recommended)" >&2
    printf "%s\n" "2) bash" >&2
    printf "%s\n" "3) zsh" >&2
    printf "%s\n" "4) both" >&2
    read -r -p "Selection [1-4]: " choice < /dev/tty
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
api_key_to_save="$(prompt_for_api_key)"
block_content="$(build_block_content)"

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
    set_api_key_in_shell_file "${f}" "${api_key_to_save}"
    upsert_block "${f}" "${block_content}"
    added=1
  fi
done

if [[ "${added}" -eq 0 ]]; then
  for f in "${shell_files[@]}"; do
    set_api_key_in_shell_file "${f}" "${api_key_to_save}"
    upsert_block "${f}" "${block_content}"
  done
fi

echo "Installed to ${DEST_DIR}"
if [[ -n "${api_key_to_save}" ]]; then
  echo "ZAI_API_KEY was added to your shell config."
else
  echo "ZAI_API_KEY was not saved by the installer."
fi
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
