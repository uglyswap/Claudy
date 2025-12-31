# Claudy

Un assistant de code IA dans votre terminal, propulse par **GLM 4.7** (Z.AI).

**Pas besoin de compte Anthropic** - Claudy utilise l'API Z.AI.

![](https://img.shields.io/badge/Node.js-18%2B-brightgreen?style=flat-square)

<img src="./demo.gif" />

---

## Fonctionnalites

- **GLM 4.7** : Modele d'IA puissant pour le code
- **Vision IA** : Analyse d'images, videos, OCR, diagrammes
- **Recherche web** : Recherche sur internet en temps reel
- **Lecture web** : Extraction du contenu de pages web
- **Mode sans permissions** : Pas de confirmations, Claudy travaille sans interruption

Tout est pre-configure. Une seule cle API pour tout.

---

## Installation

### Etape 1 : Installer Node.js (si pas deja fait)

Telechargez et installez Node.js depuis : **https://nodejs.org/**

Choisissez la version **LTS** (recommandee).

### Etape 2 : Obtenir une cle API Z.AI

1. Allez sur **https://open.z.ai/**
2. Creez un compte ou connectez-vous
3. Allez dans la gestion des cles API
4. Creez une nouvelle cle et copiez-la

### Etape 3 : Installer Claudy

**Windows** - Ouvrez PowerShell et collez :
```powershell
irm https://raw.githubusercontent.com/uglyswap/Claudy/main/install.ps1 | iex
```

**Mac / Linux** - Ouvrez le Terminal et collez :
```bash
curl -fsSL https://raw.githubusercontent.com/uglyswap/Claudy/main/install.sh | bash
```

L'installateur vous demandera votre cle API Z.AI.

---

## Utilisation

Ouvrez n'importe quel terminal et tapez :

```
claudy
```

C'est tout !

---

## Coexistence avec Claude Code CLI

Claudy est **completement isole** de Claude Code CLI officiel :

| | Claudy | Claude Code CLI |
|---|--------|----------------|
| **Commande** | `claudy` | `claude` |
| **Config** | `~/.claudy/` | `~/.claude/` |
| **API** | Z.AI (GLM 4.7) | Anthropic |

Vous pouvez installer et utiliser les deux en parallele sans aucun conflit.

---

## Serveurs MCP inclus

Ces serveurs sont automatiquement configures pendant l'installation :

| Serveur | Fonction |
|---------|----------|
| **zai-vision** | Analyse d'images, videos, OCR, interpretation de diagrammes |
| **web-search-prime** | Recherche web en temps reel |
| **web-reader** | Lecture et extraction de contenu de pages web |

Tous utilisent votre cle API Z.AI. Rien a configurer.

---

## Configuration

La configuration de Claudy est stockee dans `~/.claudy/settings.json` :

- **Windows** : `C:\Users\VotreNom\.claudy\settings.json`
- **Mac/Linux** : `~/.claudy/settings.json`

### Modifier la cle API

Editez le fichier et remplacez toutes les occurrences de votre ancienne cle par la nouvelle.

### Mode permissions

Par defaut, Claudy fonctionne en mode **bypass permissions** : il ne demande pas de confirmation pour les operations sur les fichiers ou les commandes bash. C'est le mode recommande pour une utilisation fluide.

Pour reactiver les confirmations, modifiez `~/.claudy/settings.json` :
```json
{
  "permissionMode": "default",
  "autoApprove": false
}
```

---

## FAQ

### Pourquoi "ANTHROPIC" dans les variables si on utilise Z.AI ?

Claude Code utilise ces noms de variables en interne. En changeant `ANTHROPIC_BASE_URL` vers Z.AI, toutes les requetes sont redirigees vers GLM 4.7. Pas besoin de compte Anthropic.

### J'ai deja Claude Code CLI installe, ca pose probleme ?

**Non.** Claudy utilise un dossier de configuration separe (`~/.claudy/`) et une commande differente (`claudy`). Les deux peuvent coexister sans conflit :
- `claude` → Claude Code CLI officiel (utilise `~/.claude/`)
- `claudy` → Claudy avec GLM 4.7 (utilise `~/.claudy/`)

### Comment desinstaller Claudy ?

**Etape 1** - Supprimer la commande claudy :
```bash
# Trouver ou est installe claudy
npm root -g
# Supprimer les fichiers claudy dans le dossier bin npm
```

**Etape 2** - Supprimer le dossier de configuration :
```bash
# Mac/Linux
rm -rf ~/.claudy

# Windows (PowerShell)
Remove-Item -Recurse -Force $env:USERPROFILE\.claudy
```

**Note** : Cela ne desinstalle PAS Claude Code CLI ni n'affecte sa configuration dans `~/.claude/`.

### Comment desinstaller completement (Claudy + Claude Code) ?

Si vous voulez tout supprimer :
```bash
# Desinstaller le package npm
npm uninstall -g @anthropic-ai/claude-code

# Supprimer les configurations
rm -rf ~/.claudy    # Config Claudy
rm -rf ~/.claude    # Config Claude Code CLI (si vous l'utilisez aussi)
```

---

## En savoir plus

- **GLM 4.7** : Modele d'IA developpe par Zhipu AI
- **Z.AI** : Plateforme d'API pour GLM - https://open.z.ai/
- **Claude Code** : Outil de base developpe par Anthropic
