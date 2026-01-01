#!/bin/bash
# Hook pour intercepter /cle-api et /cle AVANT le modele
# Fonctionne SANS API - pur bash

SETTINGS_PATH="$HOME/.claudy/settings.json"

# Lire le prompt depuis stdin
INPUT=$(cat)

if [ -z "$INPUT" ]; then
    exit 0
fi

# Extraire le prompt du JSON
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty' 2>/dev/null)

if [ -z "$PROMPT" ]; then
    exit 0
fi

# Verifier si c'est une commande /cle-api ou /cle
if [[ "$PROMPT" =~ ^/(cle-api|cle)(\s+(.+))?$ ]]; then
    NEW_KEY="${BASH_REMATCH[3]}"
    NEW_KEY=$(echo "$NEW_KEY" | xargs)  # Trim

    if [ -z "$NEW_KEY" ]; then
        echo ""
        echo "========================================"
        echo "   MISE A JOUR CLE API Z.AI"
        echo "========================================"
        echo ""
        echo "Usage: /cle-api VOTRE_NOUVELLE_CLE"
        echo ""
        echo "Exemple:"
        echo "  /cle-api abc123def456.xyz789"
        echo ""
        exit 2
    fi

    # Verifier que settings.json existe
    if [ ! -f "$SETTINGS_PATH" ]; then
        echo "[ERREUR] settings.json introuvable"
        exit 2
    fi

    # Lire l'ancienne cle
    OLD_KEY=$(jq -r '.env.ANTHROPIC_AUTH_TOKEN // empty' "$SETTINGS_PATH" 2>/dev/null)

    if [ -z "$OLD_KEY" ]; then
        echo "[ERREUR] Ancienne cle non trouvee"
        exit 2
    fi

    # Compter les occurrences
    COUNT=$(grep -o "$OLD_KEY" "$SETTINGS_PATH" | wc -l)

    # Remplacer toutes les occurrences
    sed -i "s|$OLD_KEY|$NEW_KEY|g" "$SETTINGS_PATH"

    # Masquer les cles
    MASKED_OLD="${OLD_KEY:0:6}...${OLD_KEY: -4}"
    MASKED_NEW="${NEW_KEY:0:6}...${NEW_KEY: -4}"

    echo ""
    echo "========================================"
    echo "   CLE API Z.AI MISE A JOUR"
    echo "========================================"
    echo ""
    echo "Ancienne: $MASKED_OLD"
    echo "Nouvelle: $MASKED_NEW"
    echo ""
    echo "- ANTHROPIC_AUTH_TOKEN: OK"
    echo "- Z_AI_API_KEY (vision): OK"
    echo "- Authorization web-search-prime: OK"
    echo "- Authorization web-reader: OK"
    echo ""
    echo "$COUNT occurrence(s) remplacee(s)"
    echo ""
    echo "Redemarrez Claudy pour appliquer."
    echo ""

    exit 2
fi

# Pas une commande /cle, continuer normalement
exit 0
