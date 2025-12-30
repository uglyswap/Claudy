# Claudy

![](https://img.shields.io/badge/Node.js-18%2B-brightgreen?style=flat-square)

Claude Code fork with custom command name. This is an agentic coding tool that lives in your terminal, understands your codebase, and helps you code faster by executing routine tasks, explaining complex code, and handling git workflows -- all through natural language commands.

<img src="./demo.gif" />

## Get started

### Using DevContainer (Recommended)

1. Clone this repository:
```bash
git clone https://github.com/uglyswap/Claudy.git
cd Claudy
```

2. Run the DevContainer setup script:

**Windows (PowerShell):**
```powershell
.\Script\run_devcontainer_claude_code.ps1 -Backend docker
# or with Podman:
.\Script\run_devcontainer_claude_code.ps1 -Backend podman
```

3. Once inside the container, run `claudy` to start.

### Manual Installation

If you want to install manually:

1. Install [Node.js 18+](https://nodejs.org/en/download/)

2. Install Claude Code:
```bash
npm install -g @anthropic-ai/claude-code
```

3. Create the `claudy` alias:

**Linux/MacOS:**
```bash
ln -s $(which claude) /usr/local/bin/claudy
# or add to your .bashrc/.zshrc:
alias claudy='claude'
```

**Windows (PowerShell as Admin):**
```powershell
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\AppData\Roaming\npm\claudy.cmd" -Target "$env:USERPROFILE\AppData\Roaming\npm\claude.cmd"
```

4. Navigate to your project directory and run `claudy`.

## Usage

Just type `claudy` in your terminal to start the interactive coding assistant.

```bash
claudy
```

## Learn more

For more information about the underlying Claude Code tool, see the [official documentation](https://docs.anthropic.com/en/docs/claude-code/overview).
