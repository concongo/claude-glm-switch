# glm-switcher

A small switcher for running Claude Code against Z.AI (GLM) models using Anthropic-compatible settings.

This is an English rewrite and clean-room implementation inspired by `claude-code-glm-switcher` by Shor73.

## What it does

- Adds launchers that set Anthropic-compatible env vars for Z.AI
- Provides a simple menu to pick native Claude vs GLM
- Keeps your API key out of the scripts (reads from env)

## Prerequisites

- macOS or Linux
- `claude` CLI installed and available on PATH
- A Z.AI API key

## Quick start

1. Set your Z.AI key in your shell profile:

```bash
export ZAI_API_KEY="YOUR_KEY_HERE"
```

2. Install the scripts and aliases:

```bash
./install.sh
```

3. Use the commands:

```bash
claude            # native Claude
claude-glm        # GLM with GLM-4.7 defaults
claude-glm-air    # GLM with GLM-4.5-Air defaults
claude-switch     # menu
```

## How the mapping works

The scripts set Anthropic-compatible environment variables so Claude Code talks to Z.AI:

- `ANTHROPIC_BASE_URL=https://api.z.ai/api/anthropic`
- `ANTHROPIC_AUTH_TOKEN=$ZAI_API_KEY`
- Default model mapping
  - `claude-glm`:
    - Opus/Sonnet -> `glm-4.7`
    - Haiku -> `glm-4.5-air`
  - `claude-glm-air`:
    - Opus/Sonnet/Haiku -> `glm-4.5-air`

You can override the defaults by setting any of these:

- `GLM_OPUS_MODEL`
- `GLM_SONNET_MODEL`
- `GLM_HAIKU_MODEL`

## Troubleshooting

- If `claude-glm` says the key is missing, make sure `ZAI_API_KEY` is exported in the shell you are using.
- If `claude` is not found, install Claude Code and make sure it is on PATH.

## Uninstall

```bash
./uninstall.sh
```

## License

MIT. See `LICENSE`.
