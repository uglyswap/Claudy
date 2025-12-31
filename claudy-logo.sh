#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
#                         ██████╗██╗      █████╗ ██╗   ██╗██████╗ ██╗   ██╗
#                        ██╔════╝██║     ██╔══██╗██║   ██║██╔══██╗╚██╗ ██╔╝
#                        ██║     ██║     ███████║██║   ██║██║  ██║ ╚████╔╝ 
#                        ██║     ██║     ██╔══██║██║   ██║██║  ██║  ╚██╔╝  
#                        ╚██████╗███████╗██║  ██║╚██████╔╝██████╔╝   ██║   
#                         ╚═════╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝    ╚═╝   
#                                    ▓▒░ CLAUDY CLI ░▒▓
# ═══════════════════════════════════════════════════════════════════════════════

# Couleurs ANSI 256
RESET="\033[0m"
BOLD="\033[1m"

# Palette dégradé: Jaune → Orange → Rose → Magenta
C1="\033[38;5;226m"  # Jaune vif
C2="\033[38;5;220m"  # Jaune-orange
C3="\033[38;5;214m"  # Orange clair
C4="\033[38;5;208m"  # Orange
C5="\033[38;5;202m"  # Orange-rose
C6="\033[38;5;204m"  # Rose-orange
C7="\033[38;5;206m"  # Rose
C8="\033[38;5;207m"  # Rose-magenta
C9="\033[38;5;213m"  # Magenta-rose

# Couleurs accent
CYAN="\033[38;5;51m"
MAGENTA="\033[38;5;201m"
YELLOW="\033[38;5;226m"

show_logo() {
    clear
    echo ""
    
    # Logo avec dégradé horizontal simulé (par sections)
    echo -e "${BOLD}${C1} ██████╗${C2}██╗      ${C3}█████╗ ${C4}██╗   ██╗${C5}██████╗ ${C6}██╗   ██╗${RESET}"
    echo -e "${BOLD}${C1}██╔════╝${C2}██║     ${C3}██╔══██╗${C4}██║   ██║${C5}██╔══██╗${C6}╚██╗ ██╔╝${RESET}"
    echo -e "${BOLD}${C2}██║     ${C3}██║     ${C4}███████║${C5}██║   ██║${C6}██║  ██║${C7} ╚████╔╝ ${RESET}"
    echo -e "${BOLD}${C3}██║     ${C4}██║     ${C5}██╔══██║${C6}██║   ██║${C7}██║  ██║${C8}  ╚██╔╝  ${RESET}"
    echo -e "${BOLD}${C4}╚██████╗${C5}███████╗${C6}██║  ██║${C7}╚██████╔╝${C8}██████╔╝${C9}   ██║   ${RESET}"
    echo -e "${BOLD}${C5} ╚═════╝${C6}╚══════╝${C7}╚═╝  ╚═╝${C8} ╚═════╝ ${C9}╚═════╝ ${C9}   ╚═╝   ${RESET}"
    
    echo ""
    
    # Ligne de séparation
    echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════${RESET}"
    
    # Signature centrée
    echo -e "                ${BOLD}${CYAN}▓▒░${C9} CLAUDY CLI ${CYAN}░▒▓${RESET}"
    
    # Tagline
    echo -e "               ${BOLD}${YELLOW}⚡ Agentic Coding ⚡${RESET}"
    
    # Ligne de fermeture
    echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════${RESET}"
    echo ""
}

show_logo_animated() {
    clear
    
    local lines=(
        " ██████╗██╗      █████╗ ██╗   ██╗██████╗ ██╗   ██╗"
        "██╔════╝██║     ██╔══██╗██║   ██║██╔══██╗╚██╗ ██╔╝"
        "██║     ██║     ███████║██║   ██║██║  ██║ ╚████╔╝ "
        "██║     ██║     ██╔══██║██║   ██║██║  ██║  ╚██╔╝  "
        "╚██████╗███████╗██║  ██║╚██████╔╝██████╔╝   ██║   "
        " ╚═════╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝    ╚═╝   "
    )
    
    local colors=("$C1" "$C2" "$C3" "$C4" "$C5" "$C6" "$C7" "$C8" "$C9")
    
    echo ""
    
    # Phase 1: Révélation ligne par ligne avec effet typing
    for i in "${!lines[@]}"; do
        local line="${lines[$i]}"
        local color_idx=$((i % ${#colors[@]}))
        local color="${colors[$color_idx]}"
        
        # Effet typing rapide
        for ((j=0; j<${#line}; j+=6)); do
            echo -ne "\r${BOLD}${color}${line:0:$((j+6))}${RESET}"
            sleep 0.01
        done
        echo -e "\r${BOLD}${color}${line}${RESET}"
    done
    
    sleep 0.1
    
    # Phase 2: Flash cyan
    echo -ne "\033[6A"  # Remonter de 6 lignes
    for line in "${lines[@]}"; do
        echo -e "${BOLD}${CYAN}${line}${RESET}"
    done
    sleep 0.05
    
    # Phase 3: Flash magenta
    echo -ne "\033[6A"
    for line in "${lines[@]}"; do
        echo -e "${BOLD}${MAGENTA}${line}${RESET}"
    done
    sleep 0.05
    
    # Phase 4: Couleurs finales avec dégradé
    echo -ne "\033[6A"
    echo -e "${BOLD}${C1} ██████╗${C2}██╗      ${C3}█████╗ ${C4}██╗   ██╗${C5}██████╗ ${C6}██╗   ██╗${RESET}"
    echo -e "${BOLD}${C1}██╔════╝${C2}██║     ${C3}██╔══██╗${C4}██║   ██║${C5}██╔══██╗${C6}╚██╗ ██╔╝${RESET}"
    echo -e "${BOLD}${C2}██║     ${C3}██║     ${C4}███████║${C5}██║   ██║${C6}██║  ██║${C7} ╚████╔╝ ${RESET}"
    echo -e "${BOLD}${C3}██║     ${C4}██║     ${C5}██╔══██║${C6}██║   ██║${C7}██║  ██║${C8}  ╚██╔╝  ${RESET}"
    echo -e "${BOLD}${C4}╚██████╗${C5}███████╗${C6}██║  ██║${C7}╚██████╔╝${C8}██████╔╝${C9}   ██║   ${RESET}"
    echo -e "${BOLD}${C5} ╚═════╝${C6}╚══════╝${C7}╚═╝  ╚═╝${C8} ╚═════╝ ${C9}╚═════╝ ${C9}   ╚═╝   ${RESET}"
    
    echo ""
    echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════${RESET}"
    echo -e "                ${BOLD}${CYAN}▓▒░${C9} CLAUDY CLI ${CYAN}░▒▓${RESET}"
    echo -e "               ${BOLD}${YELLOW}⚡ Agentic Coding ⚡${RESET}"
    echo -e "${BOLD}${MAGENTA}══════════════════════════════════════════════════${RESET}"
    echo ""
}

# Main
case "$1" in
    --no-animation|-n)
        show_logo
        ;;
    --help|-h)
        echo "Usage: claudy-logo.sh [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --no-animation, -n    Affiche le logo sans animation"
        echo "  --help, -h            Affiche cette aide"
        echo ""
        ;;
    *)
        show_logo_animated
        ;;
esac
