# Claudy

![](https://img.shields.io/badge/Node.js-18%2B-brightgreen?style=flat-square)

Claude Code with the `claudy` command. An agentic coding tool that lives in your terminal, understands your codebase, and helps you code faster.

<img src="./demo.gif" />

## Quick Install (Recommended)

### Windows (PowerShell)
```powershell
irm https://raw.githubusercontent.com/uglyswap/Claudy/main/install.ps1 | iex
```

### Linux / macOS
```bash
curl -fsSL https://raw.githubusercontent.com/uglyswap/Claudy/main/install.sh | bash
```

That's it! Now just type `claudy` in any terminal.

---

## Requirements

- [Node.js 18+](https://nodejs.org/en/download/)

---

## Usage

```bash
claudy
```

Navigate to your project directory and run `claudy` to start the interactive coding assistant.

---

## Alternative: DevContainer

If you prefer an isolated environment:

1. Clone this repository:
```bash
git clone https://github.com/uglyswap/Claudy.git
cd Claudy
```

2. Run the DevContainer setup script:

**Windows (PowerShell):**
```powershell
.\Script\run_devcontainer_claude_code.ps1 -Backend docker
```

3. Once inside the container, run `claudy`.

---

## Uninstall

```bash
npm uninstall -g @anthropic-ai/claude-code
```

Then delete the `claudy` binary from your npm bin folder if needed.

---

## Learn more

For more information about the underlying Claude Code tool, see the [official documentation](https://docs.anthropic.com/en/docs/claude-code/overview).
