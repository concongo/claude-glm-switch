# glm-switcher

![License](https://img.shields.io/badge/License-MIT-5a5a5a)
![GLM-4.7](https://img.shields.io/badge/GLM--4.7-Supported-6db33f)
![Claude Sonnet 4.5](https://img.shields.io/badge/Claude%20Sonnet%204.5-Latest-0a66c2)

A small switcher for running Claude Code against Z.AI (GLM) models using Anthropic-compatible settings.

This is an English rewrite and clean-room implementation inspired by `claude-code-glm-switcher` by Shor73.

## ✨ What it does

- Adds launchers that set Anthropic-compatible env vars for Z.AI
- Provides a simple menu to pick native Claude vs GLM variants
- Keeps your API key out of the scripts (reads from env)

## ✅ Prerequisites

- macOS or Linux
- `claude` CLI installed and available on PATH
- A Z.AI API key

## 🚀 Quick start

1. Run the installer and optionally let it add your Z.AI key to your shell config:

```bash
./install.sh
```

2. Use the commands:

```bash
claude            # native Claude
claude-glm        # GLM with GLM-4.7 defaults
claude-glm-air    # GLM with GLM-4.5-Air defaults
claude-glm-5      # GLM with GLM-5 defaults
claude-glm-5-turbo # GLM with GLM-5-Turbo defaults
claude-switch     # menu
```

## 🔀 How the mapping works

The scripts set Anthropic-compatible environment variables so Claude Code talks to Z.AI:

- `ANTHROPIC_BASE_URL=https://api.z.ai/api/anthropic`
- `ANTHROPIC_AUTH_TOKEN=$ZAI_API_KEY`
- Default model mapping
  - `claude-glm`:
    - Opus/Sonnet -> `glm-4.7`
    - Haiku -> `glm-4.5-air`
  - `claude-glm-air`:
    - Opus/Sonnet/Haiku -> `glm-4.5-air`
  - `claude-glm-5`:
    - Opus/Sonnet/Haiku -> `glm-5`
  - `claude-glm-5-turbo`:
    - Opus/Sonnet/Haiku -> `glm-5-turbo`

You can override the defaults by setting any of these:

- `GLM_OPUS_MODEL`
- `GLM_SONNET_MODEL`
- `GLM_HAIKU_MODEL`

## 🧰 Troubleshooting

- If `claude-glm` says the key is missing, make sure `ZAI_API_KEY` is exported in the shell you are using.
- If you skipped the key prompt during install, add `export ZAI_API_KEY="YOUR_KEY_HERE"` to your shell profile and reload the shell.
- If `claude` is not found, install Claude Code and make sure it is on PATH.

## 🧹 Uninstall

```bash
./uninstall.sh
```

## 📝 License

MIT. See `LICENSE`.
