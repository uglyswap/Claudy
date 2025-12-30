#!/bin/bash
#
# Claudy Installer for Linux/macOS
# Pre-configured with GLM 4.7 (Z.AI) and MCP servers
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
GRAY='\033[0;90m'
NC='\033[0m'

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}         CLAUDY INSTALLER              ${NC}"
echo -e "${CYAN}       Powered by GLM 4.7 (Z.AI)       ${NC}"
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

NPM_PREFIX=$(npm config get prefix)
NPM_BIN="$NPM_PREFIX/bin"

echo ""
echo -e "${YELLOW}Installation de Claude Code...${NC}"

# Install claude-code
npm install -g @anthropic-ai/claude-code > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo -e "${RED}[ERREUR] Echec de l'installation.${NC}"
    exit 1
fi
echo -e "${GREEN}[OK] Claude Code installe${NC}"

# Rename claude to claudy
CLAUDE_PATH="$NPM_BIN/claude"
CLAUDY_PATH="$NPM_BIN/claudy"

if [ -f "$CLAUDE_PATH" ]; then
    [ -f "$CLAUDY_PATH" ] && rm -f "$CLAUDY_PATH"
    mv "$CLAUDE_PATH" "$CLAUDY_PATH"
fi
echo -e "${GREEN}[OK] Commande 'claudy' creee${NC}"

# Create .claude directory
CLAUDE_DIR="$HOME/.claude"
mkdir -p "$CLAUDE_DIR"

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}     CONFIGURATION GLM 4.7 (Z.AI)      ${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""
echo -e "${WHITE}Pour utiliser Claudy, vous avez besoin d'une cle API Z.AI.${NC}"
echo ""
echo -e "${YELLOW}Si vous n'en avez pas encore :${NC}"
echo -e "${YELLOW}  1. Allez sur https://open.z.ai/${NC}"
echo -e "${YELLOW}  2. Creez un compte ou connectez-vous${NC}"
echo -e "${YELLOW}  3. Allez dans la gestion des cles API${NC}"
echo -e "${YELLOW}  4. Creez une nouvelle cle${NC}"
echo ""

echo -n "Entrez votre cle API Z.AI (ou appuyez sur Entree pour configurer plus tard): "
read API_KEY

SETTINGS_PATH="$CLAUDE_DIR/settings.json"

KEY_CONFIGURED=true
if [ -z "$API_KEY" ]; then
    API_KEY="VOTRE_CLE_API_ZAI_ICI"
    KEY_CONFIGURED=false
    echo ""
    echo -e "${YELLOW}[INFO] Configuration creee sans cle API.${NC}"
    echo -e "${YELLOW}       Editez le fichier suivant pour ajouter votre cle :${NC}"
    echo -e "${CYAN}       $SETTINGS_PATH${NC}"
fi

# Create settings.json with GLM config, MCP servers, and bypass permissions
cat > "$SETTINGS_PATH" << EOF
{
  "permissionMode": "bypassPermissions",
  "confirmations": {
    "fileOperations": false,
    "bashCommands": false,
    "toolUse": false
  },
  "autoApprove": true,
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "$API_KEY",
    "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic",
    "API_TIMEOUT_MS": "3000000"
  },
  "mcpServers": {
    "zai-vision": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@z_ai/mcp-server"],
      "env": {
        "Z_AI_API_KEY": "$API_KEY",
        "Z_AI_MODE": "ZAI"
      }
    },
    "web-search-prime": {
      "type": "http",
      "url": "https://api.z.ai/api/mcp/web_search_prime/mcp",
      "headers": {
        "Authorization": "Bearer $API_KEY"
      }
    },
    "web-reader": {
      "type": "http",
      "url": "https://api.z.ai/api/mcp/web_reader/mcp",
      "headers": {
        "Authorization": "Bearer $API_KEY"
      }
    }
  }
}
EOF

echo -e "${GREEN}[OK] Configuration GLM 4.7 creee${NC}"
echo -e "${GREEN}[OK] Mode bypass permissions active${NC}"
echo -e "${GREEN}[OK] 3 serveurs MCP configures :${NC}"
echo -e "${GRAY}     - zai-vision (analyse images/videos, OCR)${NC}"
echo -e "${GRAY}     - web-search-prime (recherche web)${NC}"
echo -e "${GRAY}     - web-reader (lecture de pages web)${NC}"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}      INSTALLATION TERMINEE !          ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${WHITE}Pour utiliser Claudy, tapez simplement :${NC}"
echo ""
echo -e "${CYAN}    claudy${NC}"
echo ""
if [ "$KEY_CONFIGURED" = false ]; then
    echo -e "${YELLOW}N'oubliez pas d'ajouter votre cle API Z.AI dans :${NC}"
    echo -e "${CYAN}    $SETTINGS_PATH${NC}"
    echo ""
fi
echo -e "${WHITE}Fonctionnalites incluses :${NC}"
echo -e "${GREEN}  - GLM 4.7 (pas besoin de compte Anthropic)${NC}"
echo -e "${GREEN}  - Vision IA (images, videos, OCR)${NC}"
echo -e "${GREEN}  - Recherche web${NC}"
echo -e "${GREEN}  - Lecture de pages web${NC}"
echo -e "${GREEN}  - Mode sans permissions (pas de confirmations)${NC}"
echo ""
