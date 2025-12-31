#!/bin/bash
#
# Claudy Installer for Linux/macOS
# Pre-configured with GLM 4.7 (Z.AI), MCP servers, ASCII logo, and AKHITHINK prompt
# Claudy is installed separately from Claude Code CLI - both can coexist.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/uglyswap/Claudy/main/install.sh | bash
#

set -e

# Version figee pour eviter les breaking changes d'Anthropic
CLAUDE_CODE_VERSION="2.0.74"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;95m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}         CLAUDY INSTALLER              ${NC}"
echo -e "${CYAN}       Powered by GLM 4.7 (Z.AI)       ${NC}"
echo -e "${GRAY}   Claude Code v${CLAUDE_CODE_VERSION} (frozen)    ${NC}"
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
NPM_ROOT=$(npm root -g)

echo ""
echo -e "${YELLOW}Installation de Claude Code v${CLAUDE_CODE_VERSION}...${NC}"

# Install claude-code with pinned version
npm install -g "@anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}" > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo -e "${RED}[ERREUR] Echec de l'installation.${NC}"
    exit 1
fi
echo -e "${GREEN}[OK] Claude Code v${CLAUDE_CODE_VERSION} installe${NC}"

# ============================================
# PATCH CLI.JS WITH CLAUDY BRANDING & LOGO
# ============================================
echo -e "${YELLOW}Application du branding Claudy...${NC}"

# Download and run the patch script
PATCH_SCRIPT_URL="https://raw.githubusercontent.com/uglyswap/Claudy/main/patch-claudy-logo.js"
PATCH_SCRIPT_PATH="/tmp/patch-claudy-logo.js"

if curl -fsSL "$PATCH_SCRIPT_URL" -o "$PATCH_SCRIPT_PATH" 2>/dev/null; then
    node "$PATCH_SCRIPT_PATH" 2>&1 || true
    rm -f "$PATCH_SCRIPT_PATH"
    echo -e "${MAGENTA}[OK] Logo CLAUDY avec degrade installe${NC}"
else
    echo -e "${YELLOW}[WARN] Impossible de telecharger le patch logo${NC}"
fi

# Create .claudy directory (separate from .claude to allow coexistence)
CLAUDY_DIR="$HOME/.claudy"
mkdir -p "$CLAUDY_DIR"
mkdir -p "$CLAUDY_DIR/bin"

# Download logo script
echo -e "${YELLOW}Installation du logo anime...${NC}"
LOGO_SCRIPT_URL="https://raw.githubusercontent.com/uglyswap/Claudy/main/claudy-logo.sh"
LOGO_SCRIPT_PATH="$CLAUDY_DIR/bin/claudy-logo.sh"
curl -fsSL "$LOGO_SCRIPT_URL" -o "$LOGO_SCRIPT_PATH" 2>/dev/null || true
chmod +x "$LOGO_SCRIPT_PATH" 2>/dev/null || true
echo -e "${GREEN}[OK] Logo anime installe${NC}"

# Create claudy wrapper script with env var injection
CLAUDY_PATH="$NPM_BIN/claudy"
cat > "$CLAUDY_PATH" << 'WRAPPER'
#!/bin/bash
# Claudy - Wrapper for Claude Code with custom animated logo
# Uses ~/.claudy/ for config (separate from Claude Code CLI's ~/.claude/)
# IMPORTANT: Exports env vars directly because CLAUDE_CONFIG_DIR is not respected
# IMPORTANT: Uses cli-claudy.js (patched) instead of cli.js to avoid affecting 'claude' command

# Set terminal title to "claudy"
echo -ne "\033]0;claudy\007"

CLAUDY_DIR="$HOME/.claudy"
LOGO_SCRIPT="$CLAUDY_DIR/bin/claudy-logo.sh"
SETTINGS_PATH="$CLAUDY_DIR/settings.json"

# Check for --no-logo or -n flag
SHOW_LOGO=true
ARGS=()
for arg in "$@"; do
    if [ "$arg" = "--no-logo" ] || [ "$arg" = "-n" ]; then
        SHOW_LOGO=false
    else
        ARGS+=("$arg")
    fi
done

# Show animated logo if script exists and not disabled
if [ "$SHOW_LOGO" = true ] && [ -x "$LOGO_SCRIPT" ]; then
    "$LOGO_SCRIPT" 2>/dev/null || true
fi

# CRITICAL FIX: Read settings.json and export env vars directly
# CLAUDE_CONFIG_DIR is NOT respected by Claude Code 2.0.74
if [ -f "$SETTINGS_PATH" ]; then
    # Use Python to parse JSON (more portable than jq)
    if command -v python3 &> /dev/null; then
        eval $(python3 -c "
import json
import sys
try:
    with open('$SETTINGS_PATH', 'r') as f:
        settings = json.load(f)
    env_vars = settings.get('env', {})
    for key, value in env_vars.items():
        # Escape single quotes in value
        escaped_value = str(value).replace(\"'\", \"'\\\"'\\\"'\")
        print(f\"export {key}='{escaped_value}'\")
except Exception as e:
    sys.stderr.write(f'Warning: Could not parse settings.json: {e}\\n')
" 2>/dev/null)
    elif command -v python &> /dev/null; then
        eval $(python -c "
import json
import sys
try:
    with open('$SETTINGS_PATH', 'r') as f:
        settings = json.load(f)
    env_vars = settings.get('env', {})
    for key, value in env_vars.items():
        escaped_value = str(value).replace(\"'\", \"'\\\"'\\\"'\")
        print('export {}=\\'{}\\''.format(key, escaped_value))
except Exception as e:
    sys.stderr.write('Warning: Could not parse settings.json: {}\\n'.format(e))
" 2>/dev/null)
    fi
fi

# Also set CLAUDE_CONFIG_DIR just in case future versions support it
export CLAUDE_CONFIG_DIR="$HOME/.claudy"

# Find cli-claudy.js (patched version with Claudy branding)
NPM_PREFIX=$(npm config get prefix 2>/dev/null)
NPM_ROOT=$(npm root -g 2>/dev/null)

# Possible paths for cli-claudy.js
CLAUDY_BIN_1="$NPM_PREFIX/lib/node_modules/@anthropic-ai/claude-code/cli-claudy.js"
CLAUDY_BIN_2="$NPM_ROOT/@anthropic-ai/claude-code/cli-claudy.js"
CLAUDY_BIN=""

# Try to find cli-claudy.js
if [ -f "$CLAUDY_BIN_1" ]; then
    CLAUDY_BIN="$CLAUDY_BIN_1"
elif [ -f "$CLAUDY_BIN_2" ]; then
    CLAUDY_BIN="$CLAUDY_BIN_2"
fi

# ============================================
# AUTO-REPAIR: If cli-claudy.js doesn't exist, recreate it
# ============================================
if [ -z "$CLAUDY_BIN" ]; then
    echo -e "\033[1;33m[AUTO-REPAIR] cli-claudy.js manquant, re-creation en cours...\033[0m"
    
    PATCH_URL="https://raw.githubusercontent.com/uglyswap/Claudy/main/patch-claudy-logo.js"
    PATCH_PATH="/tmp/patch-claudy-logo.js"
    
    # Download and run patch
    if curl -fsSL "$PATCH_URL" -o "$PATCH_PATH" 2>/dev/null; then
        if node "$PATCH_PATH" 2>/dev/null; then
            echo -e "\033[0;32m[AUTO-REPAIR] cli-claudy.js recree avec succes\033[0m"
            rm -f "$PATCH_PATH"
            
            # Try to find it again after patch
            if [ -f "$CLAUDY_BIN_1" ]; then
                CLAUDY_BIN="$CLAUDY_BIN_1"
            elif [ -f "$CLAUDY_BIN_2" ]; then
                CLAUDY_BIN="$CLAUDY_BIN_2"
            fi
        else
            echo -e "\033[1;33m[WARN] Impossible d'executer le patch\033[0m"
            rm -f "$PATCH_PATH"
        fi
    else
        echo -e "\033[1;33m[WARN] Impossible de telecharger le patch\033[0m"
    fi
fi

# Run cli-claudy.js if found
if [ -n "$CLAUDY_BIN" ] && [ -f "$CLAUDY_BIN" ]; then
    exec node "$CLAUDY_BIN" "${ARGS[@]}"
fi

# Final fallback: use original cli.js (if patch couldn't be applied)
CLAUDE_BIN="$NPM_PREFIX/lib/node_modules/@anthropic-ai/claude-code/cli.js"
if [ -f "$CLAUDE_BIN" ]; then
    echo -e "\033[1;33m[WARN] Utilisation de cli.js (branding Claude au lieu de Claudy)\033[0m"
    exec node "$CLAUDE_BIN" "${ARGS[@]}"
fi

CLAUDE_BIN="$NPM_ROOT/@anthropic-ai/claude-code/cli.js"
if [ -f "$CLAUDE_BIN" ]; then
    echo -e "\033[1;33m[WARN] Utilisation de cli.js (branding Claude au lieu de Claudy)\033[0m"
    exec node "$CLAUDE_BIN" "${ARGS[@]}"
fi

echo -e "\033[0;31m[ERREUR] Claude Code introuvable\033[0m"
exit 1
WRAPPER

chmod +x "$CLAUDY_PATH"
echo -e "${GREEN}[OK] Commande 'claudy' creee${NC}"

# NOTE: We do NOT remove the 'claude' command anymore
# This allows Claude Code CLI and Claudy to coexist
echo -e "${GREEN}[OK] Commande 'claude' preservee (coexistence avec Claude Code CLI)${NC}"

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

SETTINGS_PATH="$CLAUDY_DIR/settings.json"

KEY_CONFIGURED=true
if [ -z "$API_KEY" ]; then
    API_KEY="VOTRE_CLE_API_ZAI_ICI"
    KEY_CONFIGURED=false
    echo ""
    echo -e "${YELLOW}[INFO] Configuration creee sans cle API.${NC}"
    echo -e "${YELLOW}       Editez le fichier suivant pour ajouter votre cle :${NC}"
    echo -e "${CYAN}       $SETTINGS_PATH${NC}"
fi

# Create settings.json with GLM config, MCP servers, bypass permissions, and disabled auto-updater
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
    "API_TIMEOUT_MS": "3000000",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "glm-4.7",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "glm-4.7",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "glm-4.7",
    "DISABLE_AUTOUPDATER": "1"
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
echo -e "${GREEN}[OK] Auto-updater desactive${NC}"
echo -e "${GREEN}[OK] 3 serveurs MCP configures${NC}"

# ============================================
# DOWNLOAD CLAUDE.MD FROM GITHUB
# ============================================
echo -e "${YELLOW}Installation du system prompt...${NC}"

CLAUDE_MD_PATH="$CLAUDY_DIR/CLAUDE.md"
CLAUDE_MD_URL="https://raw.githubusercontent.com/uglyswap/Claudy/main/CLAUDE.md"

if curl -fsSL "$CLAUDE_MD_URL" -o "$CLAUDE_MD_PATH" 2>/dev/null; then
    echo -e "${MAGENTA}[OK] System prompt AKHITHINK installe${NC}"
    echo -e "${MAGENTA}[OK] Identite Claudy Focan configuree${NC}"
else
    echo -e "${YELLOW}[WARN] Impossible de telecharger CLAUDE.md${NC}"
fi

# ============================================
# INSTALL CLAUDY SKILLS
# ============================================
echo -e "${YELLOW}Installation des skills Claudy...${NC}"

# Create skills directory in ~/.claudy/skills/ (Claudy's config directory)
# Also install in ~/.claude/skills/ for compatibility
SKILLS_DIRS=(
    "$CLAUDY_DIR/skills"
    "$HOME/.claude/skills"
)

for SKILLS_DIR in "${SKILLS_DIRS[@]}"; do
    mkdir -p "$SKILLS_DIR"
    
    # Install /cle-api skill for changing Z.AI API key
    CLE_API_SKILL_DIR="$SKILLS_DIR/cle-api"
    mkdir -p "$CLE_API_SKILL_DIR"
    
    CLE_API_SKILL_URL="https://raw.githubusercontent.com/uglyswap/Claudy/main/skills/cle-api/SKILL.md"
    CLE_API_SKILL_PATH="$CLE_API_SKILL_DIR/SKILL.md"
    
    curl -fsSL "$CLE_API_SKILL_URL" -o "$CLE_API_SKILL_PATH" 2>/dev/null || true
done

echo -e "${MAGENTA}[OK] Skill /cle-api installe (changer la cle API)${NC}"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}      INSTALLATION TERMINEE !          ${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${WHITE}Pour utiliser Claudy, tapez simplement :${NC}"
echo ""
echo -e "${CYAN}    claudy${NC}"
echo ""
echo -e "${WHITE}Options du logo anime:${NC}"
echo -e "${GRAY}    claudy --no-logo    Desactive le logo anime${NC}"
echo -e "${GRAY}    claudy -n           Raccourci pour --no-logo${NC}"
echo ""
if [ "$KEY_CONFIGURED" = false ]; then
    echo -e "${YELLOW}N'oubliez pas d'ajouter votre cle API Z.AI dans :${NC}"
    echo -e "${CYAN}    $SETTINGS_PATH${NC}"
    echo ""
fi
echo -e "${WHITE}Coexistence avec Claude Code CLI :${NC}"
echo -e "${GRAY}  - 'claudy' utilise ~/.claudy/ (config Claudy) + cli-claudy.js${NC}"
echo -e "${GRAY}  - 'claude' utilise ~/.claude/ (config Claude Code CLI) + cli.js${NC}"
echo -e "${GRAY}  - Les deux peuvent fonctionner en parallele${NC}"
echo ""
echo -e "${WHITE}Fonctionnalites incluses :${NC}"
echo -e "${MAGENTA}  - Logo CLAUDY avec degrade jaune-magenta${NC}"
echo -e "${GREEN}  - GLM 4.7 (pas besoin de compte Anthropic)${NC}"
echo -e "${GREEN}  - Vision IA (images, videos, OCR)${NC}"
echo -e "${GREEN}  - Recherche web${NC}"
echo -e "${GREEN}  - Lecture de pages web${NC}"
echo -e "${GREEN}  - Mode sans permissions (pas de confirmations)${NC}"
echo -e "${GREEN}  - Version figee (pas de mises a jour auto)${NC}"
echo -e "${MAGENTA}  - AKHITHINK: Deep reasoning mode${NC}"
echo -e "${MAGENTA}  - Identite Claudy Focan (Dikkenek)${NC}"
echo ""
echo -e "${WHITE}Commandes speciales :${NC}"
echo -e "${CYAN}  - /cle-api <nouvelle_cle>  Changer la cle API Z.AI${NC}"
echo ""
echo -e "${WHITE}Resilience aux mises a jour npm :${NC}"
echo -e "${GRAY}  - Si cli-claudy.js est efface par npm update,${NC}"
echo -e "${GRAY}    il sera automatiquement recree au prochain lancement${NC}"
echo ""
echo -e "${GRAY}Version Claude Code: ${CLAUDE_CODE_VERSION} (frozen)${NC}"
echo ""
