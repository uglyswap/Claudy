#!/bin/bash
#
# Claudy Installer for Linux/macOS
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/uglyswap/Claudy/main/install.sh | bash
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}         CLAUDY INSTALLER              ${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo -e "${RED}[ERREUR] Node.js n'est pas installe.${NC}"
    echo ""
    echo -e "${YELLOW}Telechargez Node.js ici : https://nodejs.org/${NC}"
    echo -e "${YELLOW}Choisissez la version LTS (recommandee).${NC}"
    echo ""
    exit 1
fi

NODE_VERSION=$(node --version | sed 's/v//')
NODE_MAJOR=$(echo $NODE_VERSION | cut -d. -f1)
if [ "$NODE_MAJOR" -lt 18 ]; then
    echo -e "${RED}[ERREUR] Node.js 18 ou superieur est requis.${NC}"
    echo -e "${RED}Version actuelle : $NODE_VERSION${NC}"
    echo ""
    echo -e "${YELLOW}Telechargez la derniere version : https://nodejs.org/${NC}"
    echo ""
    exit 1
fi
echo -e "${GREEN}[OK] Node.js $NODE_VERSION${NC}"

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo -e "${RED}[ERREUR] npm n'est pas installe.${NC}"
    exit 1
fi
echo -e "${GREEN}[OK] npm${NC}"

# Check if 'claude' command already exists (from another software)
NPM_PREFIX=$(npm config get prefix)
if command -v claude &> /dev/null; then
    EXISTING_CLAUDE=$(which claude)
    if [[ "$EXISTING_CLAUDE" != "$NPM_PREFIX"* ]]; then
        echo ""
        echo -e "${YELLOW}[INFO] Une commande 'claude' existe deja sur votre systeme :${NC}"
        echo -e "${YELLOW}       $EXISTING_CLAUDE${NC}"
        echo -e "${YELLOW}       Claudy n'y touchera PAS. Votre logiciel existant reste intact.${NC}"
        echo ""
    fi
fi

NPM_BIN="$NPM_PREFIX/bin"

echo ""
echo -e "${YELLOW}Installation en cours...${NC}"
echo ""

# Install claude-code
npm install -g @anthropic-ai/claude-code > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo -e "${RED}[ERREUR] Echec de l'installation.${NC}"
    exit 1
fi

# Rename claude to claudy in npm folder only
CLAUDE_PATH="$NPM_BIN/claude"
CLAUDY_PATH="$NPM_BIN/claudy"

if [ -f "$CLAUDE_PATH" ]; then
    [ -f "$CLAUDY_PATH" ] && rm -f "$CLAUDY_PATH"
    mv "$CLAUDE_PATH" "$CLAUDY_PATH"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}      INSTALLATION TERMINEE !          ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${WHITE}Pour utiliser Claudy, tapez simplement :${NC}"
echo ""
echo -e "${CYAN}    claudy${NC}"
echo ""
echo -e "${WHITE}C'est tout ! Bonne utilisation.${NC}"
echo ""
