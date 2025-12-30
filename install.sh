#!/bin/bash
#
# Claudy Installer for Linux/macOS
# Installs @anthropic-ai/claude-code and renames 'claude' to 'claudy'
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/uglyswap/Claudy/main/install.sh | bash
#

set -e

echo "=== Claudy Installer ==="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo -e "${RED}[ERROR] Node.js is not installed.${NC}"
    echo "Please install Node.js 18+ from https://nodejs.org/"
    exit 1
fi

NODE_VERSION=$(node --version | sed 's/v//')
NODE_MAJOR=$(echo $NODE_VERSION | cut -d. -f1)
if [ "$NODE_MAJOR" -lt 18 ]; then
    echo -e "${RED}[ERROR] Node.js 18+ is required. Current version: $NODE_VERSION${NC}"
    exit 1
fi
echo -e "${GREEN}[OK] Node.js $NODE_VERSION detected${NC}"

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo -e "${RED}[ERROR] npm is not installed.${NC}"
    exit 1
fi
echo -e "${GREEN}[OK] npm detected${NC}"

# Get npm global bin path
NPM_BIN=$(npm config get prefix)/bin

echo -e "\n${YELLOW}Installing @anthropic-ai/claude-code...${NC}"
npm install -g @anthropic-ai/claude-code

if [ $? -ne 0 ]; then
    echo -e "${RED}[ERROR] Failed to install @anthropic-ai/claude-code${NC}"
    exit 1
fi
echo -e "${GREEN}[OK] claude-code installed${NC}"

# Find claude binary path
CLAUDE_PATH=$(which claude 2>/dev/null || echo "$NPM_BIN/claude")
CLAUDY_PATH="${CLAUDE_PATH%claude}claudy"

echo -e "\n${YELLOW}Renaming 'claude' to 'claudy'...${NC}"

if [ -f "$CLAUDE_PATH" ]; then
    # Remove existing claudy if present
    [ -f "$CLAUDY_PATH" ] && rm -f "$CLAUDY_PATH"
    
    # Move claude to claudy
    mv "$CLAUDE_PATH" "$CLAUDY_PATH"
    echo -e "${GREEN}[OK] $CLAUDE_PATH -> $CLAUDY_PATH${NC}"
else
    echo -e "${RED}[ERROR] Could not find claude binary at $CLAUDE_PATH${NC}"
    exit 1
fi

echo -e "\n${CYAN}=== Installation Complete! ===${NC}"
echo -e "${GREEN}You can now use 'claudy' in any terminal.${NC}"
echo -e "\n${YELLOW}Try it now:${NC}"
echo "  claudy"
