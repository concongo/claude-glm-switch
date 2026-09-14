# glm-switcher

![License](https://img.shields.io/badge/License-MIT-5a5a5a)
![GLM-5.3](https://img.shields.io/badge/GLM--5.3-Supported-6db33f)
![LiteLLM](https://img.shields.io/badge/LiteLLM-Proxy-0a66c2)

A small switcher for running Claude Code against Z.AI (GLM) models or your LiteLLM proxy using Anthropic-compatible settings.

This is an English rewrite and clean-room implementation inspired by `claude-code-glm-switcher` by Shor73.

## ✨ What it does

- Adds launchers that set Anthropic-compatible env vars for Z.AI or LiteLLM
- Provides a menu to pick native Claude, GLM variants, or LiteLLM
- Reads API keys from the environment rather than storing them in scripts

## ✅ Prerequisites

- macOS or Linux
- `claude` CLI installed and available on PATH
- A Z.AI API key for direct GLM launchers, or a LiteLLM proxy URL and key for LiteLLM launchers

## 🚀 Quick start

1. Run the installer. It can optionally add your Z.AI key to your shell config:

```bash
./install.sh
```

2. Use the commands:

```bash
claude            # native Claude
claude-glm        # direct Z.AI, GLM-5.3
claude-glm-53     # same as claude-glm
claude-glm-53-flash # direct Z.AI, GLM-5.3-Flash
claude-litellm    # LiteLLM proxy with your configured model
claude-switch     # menu
```

## 🔀 How the mapping works

The direct GLM scripts set Anthropic-compatible environment variables so Claude Code talks to Z.AI:

- `ANTHROPIC_BASE_URL=https://api.z.ai/api/anthropic`
- `ANTHROPIC_AUTH_TOKEN=$ZAI_API_KEY`
- `claude-glm` and `claude-glm-53` map Opus, Sonnet, and Haiku to `glm-5.3`
- `claude-glm-53-flash` maps all three to `glm-5.3-flash`

You can override the defaults by setting any of these:

- `GLM_OPUS_MODEL`
- `GLM_SONNET_MODEL`
- `GLM_HAIKU_MODEL`

For LiteLLM, set `LITELLM_BASE_URL` to the proxy root URL, `LITELLM_API_KEY` to its proxy key, and `LITELLM_MODEL` to a `model_name` exposed by the proxy. You can put these in the current directory's `.env`, in the installed switcher's `.env`, or export them in your shell. The LiteLLM launcher sets `ANTHROPIC_BASE_URL` and `ANTHROPIC_AUTH_TOKEN` from those values. The proxy must expose its [Anthropic-compatible endpoint](https://docs.anthropic.com/en/docs/claude-code/llm-gateway).

```bash
export LITELLM_BASE_URL="http://localhost:4000"
export LITELLM_API_KEY="YOUR_PROXY_KEY"
export LITELLM_MODEL="YOUR_PROXY_MODEL_NAME"
claude-litellm
```

`claude-litellm` maps Opus, Sonnet, and Haiku to `LITELLM_MODEL`. You can override individual slots with `LITELLM_OPUS_MODEL`, `LITELLM_SONNET_MODEL`, and `LITELLM_HAIKU_MODEL`.

Claude Code may warn that a LiteLLM model alias is missing from its model catalog and assume a 200k context window. If the model behind that alias and your proxy both support a larger window, set `CLAUDE_CODE_MAX_CONTEXT_TOKENS` to the real token count in the same shell or `.env`. For example, Ollama lists `deepseek-v4.1-flash:cloud` with a 1M window, so an alias routed to that model can use `CLAUDE_CODE_MAX_CONTEXT_TOKENS=1000000`. This changes Claude Code's compaction limit without changing the model name sent to LiteLLM. A startup notice about an unrecognized model can still appear; the declared window is then used for compaction. Avoid `CLAUDE_CODE_DISABLE_UNKNOWN_MODEL_WINDOW_ENFORCEMENT=1` unless your gateway passes through a context-limit error Claude Code can recognize, because that setting delays compaction until an API rejection. See [Claude Code's context-window guidance](https://code.claude.com/docs/en/model-config#correct-the-window-for-a-gateway-or-custom-model-id) and [Ollama's model page](https://ollama.com/library/deepseek-v4.1-flash).

## 🧰 Troubleshooting

- If `claude-glm` says the key is missing, make sure `ZAI_API_KEY` is exported in the shell you are using.
- If `claude-litellm` says its URL, key, or model is missing, set `LITELLM_BASE_URL`, `LITELLM_API_KEY`, and `LITELLM_MODEL` before launching it.
- If you skipped the key prompt during install, add `export ZAI_API_KEY="YOUR_KEY_HERE"` to your shell profile and reload the shell.
- If `claude` is not found, install Claude Code and make sure it is on PATH.

## 🧹 Uninstall

```bash
./uninstall.sh
```

## 📝 License

MIT. See `LICENSE`.
