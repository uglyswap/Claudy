#!/bin/bash
#
# Claudy Uninstaller for Linux/macOS
#
# This script removes:
# - ~/.claudy/ folder (all files and subfolders)
# - ~/.claudy/bin from shell PATH configuration
#
# It does NOT touch:
# - Claude Code CLI (claude command)
# - ~/.claude/ folder
# - Any other npm packages
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/uglyswap/Claudy/main/uninstall.sh | bash
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
echo -e "${CYAN}      CLAUDY UNINSTALLER               ${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

CLAUDY_DIR="$HOME/.claudy"

# Check if Claudy is installed
if [ ! -d "$CLAUDY_DIR" ]; then
    echo -e "${YELLOW}[INFO] Claudy n'est pas installe sur ce systeme.${NC}"
    echo ""
    exit 0
fi

# Calculate size
SIZE=$(du -sh "$CLAUDY_DIR" 2>/dev/null | cut -f1)

echo -e "${WHITE}Composants detectes:${NC}"
echo -e "  ${YELLOW}[X] Dossier ~/.claudy/ ($SIZE)${NC}"

# Check PATH in shell configs
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

if grep -q ".claudy/bin" "$SHELL_RC" 2>/dev/null; then
    echo -e "  ${YELLOW}[X] PATH dans $SHELL_RC${NC}"
    PATH_IN_RC=true
else
    echo -e "  ${GRAY}[ ] PATH dans $SHELL_RC (non trouve)${NC}"
    PATH_IN_RC=false
fi

echo ""
echo -e "${GREEN}Claude Code (officiel) ne sera PAS touche:${NC}"
echo -e "${GRAY}  - Commande 'claude' preservee${NC}"
echo -e "${GRAY}  - Dossier ~/.claude/ preserve${NC}"
echo ""

# Confirm uninstallation
echo -n "Voulez-vous desinstaller Claudy? (O/n) "
read -r confirm

if [ "$confirm" = "n" ] || [ "$confirm" = "N" ]; then
    echo ""
    echo -e "${YELLOW}[ANNULE] Desinstallation annulee.${NC}"
    exit 0
fi

echo ""
echo -e "${YELLOW}Desinstallation en cours...${NC}"
echo ""

ERRORS=0

# Step 1: Remove ~/.claudy/ folder
if rm -rf "$CLAUDY_DIR" 2>/dev/null; then
    echo -e "${GREEN}[OK] Dossier ~/.claudy/ supprime${NC}"
else
    echo -e "${RED}[ERREUR] Impossible de supprimer ~/.claudy/${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Step 2: Remove PATH from shell config
if [ "$PATH_IN_RC" = true ]; then
    if [ -f "$SHELL_RC" ]; then
        # Create backup
        cp "$SHELL_RC" "${SHELL_RC}.claudy-backup"
        
        # Remove claudy PATH lines
        if sed -i.tmp '/\.claudy\/bin/d' "$SHELL_RC" 2>/dev/null || \
           sed -i '' '/\.claudy\/bin/d' "$SHELL_RC" 2>/dev/null; then
            # Also remove the comment line
            sed -i.tmp '/Claudy - Independent Claude Code/d' "$SHELL_RC" 2>/dev/null || \
            sed -i '' '/Claudy - Independent Claude Code/d' "$SHELL_RC" 2>/dev/null
            
            # Clean up temp files
            rm -f "${SHELL_RC}.tmp"
            
            echo -e "${GREEN}[OK] PATH retire de $SHELL_RC${NC}"
        else
            echo -e "${RED}[ERREUR] Impossible de modifier $SHELL_RC${NC}"
            ERRORS=$((ERRORS + 1))
        fi
    fi
fi

# Final status
echo ""
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}   CLAUDY DESINSTALLE AVEC SUCCES !    ${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${WHITE}La commande 'claudy' n'est plus disponible.${NC}"
    echo ""
    echo -e "${YELLOW}Redemarrez votre terminal ou executez:${NC}"
    echo -e "${CYAN}  source $SHELL_RC${NC}"
    echo ""
    echo -e "${GRAY}Pour reinstaller Claudy:${NC}"
    echo -e "${CYAN}  curl -fsSL https://raw.githubusercontent.com/uglyswap/Claudy/main/install.sh | bash${NC}"
else
    echo -e "${YELLOW}========================================${NC}"
    echo -e "${YELLOW}  DESINSTALLATION PARTIELLE            ${NC}"
    echo -e "${YELLOW}========================================${NC}"
    echo ""
    echo -e "${RED}Certains composants n'ont pas pu etre supprimes.${NC}"
    echo ""
    echo -e "${YELLOW}Essayez de:${NC}"
    echo -e "${GRAY}  1. Fermer toutes les instances de Claudy${NC}"
    echo -e "${GRAY}  2. Relancer ce script avec sudo${NC}"
fi

echo ""
