#!/bin/bash
#
# Claudy Installer for Linux/macOS
# Pre-configured with GLM 4.7 (Z.AI), MCP servers, ASCII logo, and AKHITHINK prompt
# Claudy is installed INDEPENDENTLY from Claude Code CLI - completely separate installations.
#
# This means:
# - Uninstalling Claude Code does NOT affect Claudy
# - Updating Claude Code does NOT affect Claudy
# - Both programs are 100% independent
# - claudy uses cli-claudy.js, claude uses cli.js
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
echo -e "${YELLOW}      INSTALLATION INDEPENDANTE        ${NC}"
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

# ============================================
# CREATE ISOLATED CLAUDY INSTALLATION
# ============================================
CLAUDY_DIR="$HOME/.claudy"
CLAUDY_LIB_DIR="$CLAUDY_DIR/lib"
CLAUDY_BIN_DIR="$CLAUDY_DIR/bin"
CLAUDY_HOOKS_DIR="$CLAUDY_DIR/hooks"

# Create directories
mkdir -p "$CLAUDY_DIR"
mkdir -p "$CLAUDY_LIB_DIR"
mkdir -p "$CLAUDY_BIN_DIR"
mkdir -p "$CLAUDY_HOOKS_DIR"

echo ""
echo -e "${YELLOW}Installation de Claude Code v${CLAUDE_CODE_VERSION} dans ~/.claudy/lib/...${NC}"
echo -e "${GRAY}(Installation isolee, independante de npm global)${NC}"

# Initialize package.json in lib directory if not exists
PACKAGE_JSON_PATH="$CLAUDY_LIB_DIR/package.json"
if [ ! -f "$PACKAGE_JSON_PATH" ]; then
    cat > "$PACKAGE_JSON_PATH" << 'EOF'
{
  "name": "claudy-local",
  "version": "1.0.0",
  "description": "Claudy isolated installation",
  "private": true
}
EOF
fi

# Install claude-code locally in ~/.claudy/lib/
cd "$CLAUDY_LIB_DIR"
npm install "@anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}" > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo -e "${RED}[ERREUR] Echec de l'installation.${NC}"
    exit 1
fi
echo -e "${GREEN}[OK] Claude Code v${CLAUDE_CODE_VERSION} installe dans ~/.claudy/lib/${NC}"

# ============================================
# PATCH CLI.JS WITH CLAUDY BRANDING & LOGO
# ============================================
echo -e "${YELLOW}Application du branding Claudy...${NC}"

# Download and run the patch script with local path
PATCH_SCRIPT_URL="https://raw.githubusercontent.com/uglyswap/Claudy/main/patch-claudy-logo.js"
PATCH_SCRIPT_PATH="/tmp/patch-claudy-logo.js"

if curl -fsSL "$PATCH_SCRIPT_URL" -o "$PATCH_SCRIPT_PATH" 2>/dev/null; then
    # Pass the local installation path as argument
    node "$PATCH_SCRIPT_PATH" "$CLAUDY_LIB_DIR" 2>&1 || true
    rm -f "$PATCH_SCRIPT_PATH"
    echo -e "${MAGENTA}[OK] cli-claudy.js cree avec logo CLAUDY${NC}"
else
    echo -e "${YELLOW}[WARN] Impossible de telecharger le patch logo${NC}"
fi

# Download logo script
echo -e "${YELLOW}Installation du logo anime...${NC}"
LOGO_SCRIPT_URL="https://raw.githubusercontent.com/uglyswap/Claudy/main/claudy-logo.sh"
LOGO_SCRIPT_PATH="$CLAUDY_BIN_DIR/claudy-logo.sh"
curl -fsSL "$LOGO_SCRIPT_URL" -o "$LOGO_SCRIPT_PATH" 2>/dev/null || true
chmod +x "$LOGO_SCRIPT_PATH" 2>/dev/null || true
echo -e "${GREEN}[OK] Logo anime installe${NC}"

# ============================================
# CREATE CLAUDY WRAPPER SCRIPT WITH API KEY VALIDATION
# ============================================
CLAUDY_WRAPPER_PATH="$CLAUDY_BIN_DIR/claudy"
cat > "$CLAUDY_WRAPPER_PATH" << 'WRAPPER'
#!/bin/bash
# Claudy - Independent installation wrapper
# Uses ~/.claudy/ for EVERYTHING (config + code)
# Completely independent from Claude Code CLI
# - claudy uses cli-claudy.js (patched)
# - claude uses cli.js (original)

# Set terminal title to "claudy"
echo -ne "\033]0;claudy\007"

CLAUDY_DIR="$HOME/.claudy"
CLAUDY_LIB_DIR="$CLAUDY_DIR/lib"
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

# ============================================
# API KEY VALIDATION AT STARTUP (SILENT)
# ============================================

test_api_key() {
    local key="$1"
    
    # Check for placeholder or empty key
    if [ -z "$key" ] || [ "$key" = "VOTRE_CLE_API_ZAI_ICI" ] || [ ${#key} -lt 10 ]; then
        return 1
    fi
    
    # Test the API key silently
    local response
    response=$(curl -s -o /dev/null -w "%{http_code}" \
        -X POST "https://api.z.ai/api/anthropic/v1/messages" \
        -H "Authorization: Bearer $key" \
        -H "Content-Type: application/json" \
        -d '{"model":"glm-4.7","max_tokens":1,"messages":[{"role":"user","content":"test"}]}' \
        --connect-timeout 10 2>/dev/null)
    
    if [ "$response" = "401" ] || [ "$response" = "403" ]; then
        return 1
    fi
    return 0
}

update_api_key() {
    local new_key="$1"
    local old_key="$2"
    
    if [ -f "$SETTINGS_PATH" ]; then
        # Use sed to replace all occurrences
        sed -i.bak "s|$old_key|$new_key|g" "$SETTINGS_PATH"
        rm -f "${SETTINGS_PATH}.bak"
        return 0
    fi
    return 1
}

prompt_for_new_key() {
    local reason="$1"
    
    echo ""
    echo -e "\033[1;33m========================================\033[0m"
    echo -e "\033[1;33m   CLE API Z.AI INVALIDE OU MANQUANTE  \033[0m"
    echo -e "\033[1;33m========================================\033[0m"
    echo ""
    echo -e "\033[0;90mRaison: $reason\033[0m"
    echo ""
    echo -e "\033[0;36mEntrez votre nouvelle cle API Z.AI:\033[0m"
    read -r new_key
    
    if [ -z "$new_key" ]; then
        echo -e "\033[0;31m[ERREUR] La cle ne peut pas etre vide.\033[0m"
        return 1
    fi
    
    echo "$new_key"
}

# Read current API key from settings.json
API_KEY=""
if [ -f "$SETTINGS_PATH" ]; then
    if command -v python3 &> /dev/null; then
        API_KEY=$(python3 -c "
import json
try:
    with open('$SETTINGS_PATH', 'r') as f:
        settings = json.load(f)
    print(settings.get('env', {}).get('ANTHROPIC_AUTH_TOKEN', ''))
except:
    pass
" 2>/dev/null)
    elif command -v python &> /dev/null; then
        API_KEY=$(python -c "
import json
try:
    with open('$SETTINGS_PATH', 'r') as f:
        settings = json.load(f)
    print(settings.get('env', {}).get('ANTHROPIC_AUTH_TOKEN', ''))
except:
    pass
" 2>/dev/null)
    fi
fi

# Check if API key needs update
KEY_NEEDS_UPDATE=false
UPDATE_REASON=""

if [ -z "$API_KEY" ]; then
    KEY_NEEDS_UPDATE=true
    UPDATE_REASON="Aucune cle API trouvee dans settings.json"
elif [ "$API_KEY" = "VOTRE_CLE_API_ZAI_ICI" ]; then
    KEY_NEEDS_UPDATE=true
    UPDATE_REASON="Cle API placeholder detectee"
else
    # Test the API key silently (no message)
    if ! test_api_key "$API_KEY"; then
        KEY_NEEDS_UPDATE=true
        UPDATE_REASON="Cle API invalide ou expiree (erreur 401/403)"
    fi
fi

# If key needs update, prompt for new one
if [ "$KEY_NEEDS_UPDATE" = true ]; then
    NEW_KEY=$(prompt_for_new_key "$UPDATE_REASON")
    
    if [ -n "$NEW_KEY" ]; then
        OLD_KEY_TO_REPLACE="${API_KEY:-VOTRE_CLE_API_ZAI_ICI}"
        
        if update_api_key "$NEW_KEY" "$OLD_KEY_TO_REPLACE"; then
            echo ""
            echo -e "\033[0;32m[OK] Cle API mise a jour dans les 4 emplacements\033[0m"
            echo ""
            API_KEY="$NEW_KEY"
        else
            echo -e "\033[0;31m[ERREUR] Impossible de mettre a jour settings.json\033[0m"
            exit 1
        fi
    else
        echo -e "\033[0;31m[ERREUR] Cle API requise pour utiliser Claudy.\033[0m"
        exit 1
    fi
fi

# ============================================
# EXPORT ENVIRONMENT VARIABLES
# ============================================

if [ -f "$SETTINGS_PATH" ]; then
    if command -v python3 &> /dev/null; then
        eval $(python3 -c "
import json
import sys
try:
    with open('$SETTINGS_PATH', 'r') as f:
        settings = json.load(f)
    env_vars = settings.get('env', {})
    for key, value in env_vars.items():
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

# Set config dir
export CLAUDE_CONFIG_DIR="$HOME/.claudy"

# Path to our isolated cli-claudy.js (PATCHED version)
CLAUDY_EXE="$CLAUDY_LIB_DIR/node_modules/@anthropic-ai/claude-code/cli-claudy.js"

# AUTO-REPAIR: If cli-claudy.js doesn't exist, recreate it
if [ ! -f "$CLAUDY_EXE" ]; then
    echo -e "\033[1;33m[AUTO-REPAIR] cli-claudy.js manquant, re-creation en cours...\033[0m"
    
    PATCH_URL="https://raw.githubusercontent.com/uglyswap/Claudy/main/patch-claudy-logo.js"
    PATCH_PATH="/tmp/patch-claudy-logo.js"
    
    if curl -fsSL "$PATCH_URL" -o "$PATCH_PATH" 2>/dev/null; then
        if node "$PATCH_PATH" "$CLAUDY_LIB_DIR" 2>/dev/null; then
            echo -e "\033[0;32m[AUTO-REPAIR] cli-claudy.js recree avec succes\033[0m"
            rm -f "$PATCH_PATH"
        else
            echo -e "\033[1;33m[WARN] Impossible d'executer le patch\033[0m"
            rm -f "$PATCH_PATH"
        fi
    else
        echo -e "\033[1;33m[WARN] Impossible de telecharger le patch\033[0m"
    fi
fi

# Fallback to cli.js if cli-claudy.js still doesn't exist
if [ ! -f "$CLAUDY_EXE" ]; then
    CLAUDY_EXE="$CLAUDY_LIB_DIR/node_modules/@anthropic-ai/claude-code/cli.js"
fi

if [ -f "$CLAUDY_EXE" ]; then
    # Always add --dangerously-skip-permissions to bypass folder confirmation
    # Claudy trusts all directories by default (no "Do you want to work in this folder?" prompt)
    exec node "$CLAUDY_EXE" --dangerously-skip-permissions "${ARGS[@]}"
else
    echo -e "\033[0;31m[ERREUR] Claudy introuvable. Reinstallez avec:\033[0m"
    echo -e "\033[1;33mcurl -fsSL https://raw.githubusercontent.com/uglyswap/Claudy/main/install.sh | bash\033[0m"
    exit 1
fi
WRAPPER

chmod +x "$CLAUDY_WRAPPER_PATH"
echo -e "${GREEN}[OK] Wrapper Claudy cree dans ~/.claudy/bin/${NC}"

# ============================================
# ADD CLAUDY TO PATH
# ============================================
echo -e "${YELLOW}Configuration du PATH...${NC}"

# Detect shell and config file
SHELL_NAME=$(basename "$SHELL")
case "$SHELL_NAME" in
    bash)
        if [ -f "$HOME/.bash_profile" ]; then
            SHELL_RC="$HOME/.bash_profile"
        else
            SHELL_RC="$HOME/.bashrc"
        fi
        ;;
    zsh)
        SHELL_RC="$HOME/.zshrc"
        ;;
    *)
        SHELL_RC="$HOME/.profile"
        ;;
esac

# Add to PATH if not already there
PATH_LINE='export PATH="$HOME/.claudy/bin:$PATH"'
if ! grep -q ".claudy/bin" "$SHELL_RC" 2>/dev/null; then
    echo "" >> "$SHELL_RC"
    echo "# Claudy - Independent Claude Code installation" >> "$SHELL_RC"
    echo "$PATH_LINE" >> "$SHELL_RC"
    echo -e "${GREEN}[OK] ~/.claudy/bin/ ajoute au PATH dans $SHELL_RC${NC}"
    echo -e "${YELLOW}[INFO] Executez 'source $SHELL_RC' ou redemarrez votre terminal${NC}"
else
    echo -e "${GREEN}[OK] ~/.claudy/bin/ deja dans le PATH${NC}"
fi

# Also add to current session
export PATH="$HOME/.claudy/bin:$PATH"

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
    echo -e "${YELLOW}       Au demarrage de Claudy, il vous demandera votre cle.${NC}"
fi

# Create settings.json with GLM config, MCP servers, bypass permissions
# NOTE: No hooks - /cle-api is now a native command injected in cli-claudy.js
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
    echo -e "${YELLOW}Au premier demarrage, Claudy vous demandera votre cle API Z.AI.${NC}"
    echo ""
fi
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}       INDEPENDANCE TOTALE             ${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""
echo -e "${WHITE}Claudy est 100% independant de Claude Code :${NC}"
echo -e "${GRAY}  - Installation isolee : ~/.claudy/lib/${NC}"
echo -e "${GRAY}  - CLI patche : cli-claudy.js (pas cli.js)${NC}"
echo -e "${GRAY}  - Configuration isolee : ~/.claudy/settings.json${NC}"
echo -e "${GRAY}  - Binaires isoles : ~/.claudy/bin/${NC}"
echo ""
echo -e "${WHITE}Claude Code (officiel) reste intact :${NC}"
echo -e "${GRAY}  - Commande 'claude' inchangee${NC}"
echo -e "${GRAY}  - Utilise ~/.claude/ (pas ~/.claudy/)${NC}"
echo -e "${GRAY}  - Aucune modification de cli.js${NC}"
echo ""
echo -e "${WHITE}Fonctionnalites Claudy :${NC}"
echo -e "${MAGENTA}  - Logo CLAUDY avec degrade jaune-magenta${NC}"
echo -e "${GREEN}  - GLM 4.7 (pas besoin de compte Anthropic)${NC}"
echo -e "${GREEN}  - Vision IA (images, videos, OCR)${NC}"
echo -e "${GREEN}  - Recherche web${NC}"
echo -e "${GREEN}  - Lecture de pages web${NC}"
echo -e "${GREEN}  - Mode sans permissions (pas de confirmations)${NC}"
echo -e "${GREEN}  - Version figee ${CLAUDE_CODE_VERSION} (pas de mises a jour auto)${NC}"
echo -e "${MAGENTA}  - AKHITHINK: Deep reasoning mode${NC}"
echo -e "${MAGENTA}  - Identite Claudy Focan (Dikkenek)${NC}"
echo -e "${CYAN}  - /cle-api: Changer la cle API (natif, sans modele)${NC}"
echo ""
echo -e "${GRAY}Structure d'installation :${NC}"
echo -e "${GRAY}  ~/.claudy/${NC}"
echo -e "${GRAY}    +-- bin/           (claudy)${NC}"
echo -e "${GRAY}    +-- lib/           (node_modules avec cli-claudy.js)${NC}"
echo -e "${GRAY}    +-- settings.json  (configuration)${NC}"
echo -e "${GRAY}    +-- CLAUDE.md      (system prompt)${NC}"
echo ""
