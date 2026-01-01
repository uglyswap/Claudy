# Claudy

Un assistant de code IA dans votre terminal, propulsé par **GLM 4.7** (Z.AI).

**Pas besoin de compte Anthropic** - Claudy utilise l'API Z.AI.

![](https://img.shields.io/badge/Node.js-18%2B-brightgreen?style=flat-square)
![](https://img.shields.io/badge/100%25-Ind%C3%A9pendant-blue?style=flat-square)

<img src="./demo.gif" />

---

## 🎯 100% Indépendant

Claudy est **complètement isolé** de Claude Code CLI. Les deux programmes sont entièrement indépendants :

```
~/.claudy/                          # Installation Claudy (isolée)
├── bin/                            # Commande claudy
├── hooks/                          # Hooks (commandes sans modèle)
├── lib/                            # node_modules isolés
│   └── node_modules/
│       └── @anthropic-ai/claude-code/
├── settings.json                   # Configuration Claudy
└── CLAUDE.md                       # System prompt

~/.claude/                          # Installation Claude Code (séparée)
└── ...                             # Aucun partage avec Claudy
```

### Ce qui n'affecte PAS Claudy

| Action | Impact sur Claudy |
|--------|-------------------|
| `npm uninstall -g @anthropic-ai/claude-code` | ✅ Aucun impact |
| `npm update @anthropic-ai/claude-code` | ✅ Aucun impact |
| Modifier `~/.claude/settings.json` | ✅ Aucun impact |
| Désinstaller Claude Code | ✅ Aucun impact |

---

## Fonctionnalités

- **GLM 4.7** : Modèle d'IA puissant pour le code
- **Vision IA** : Analyse d'images, vidéos, OCR, diagrammes
- **Recherche web** : Recherche sur internet en temps réel
- **Lecture web** : Extraction du contenu de pages web
- **Mode sans permissions** : Pas de confirmations, Claudy travaille sans interruption
- **AKHITHINK** : Mode de réflexion profonde avec animation rainbow 🌈
- **Installation isolée** : 100% indépendant de Claude Code CLI

Tout est pré-configuré. Une seule clé API pour tout.

---

## ⚡ Commande AKHITHINK

**AKHITHINK** est la commande signature de Claudy pour activer le mode réflexion profonde.

### Comment l'utiliser

Tapez simplement `akhithink` suivi de votre question :

```
akhithink comment optimiser cette architecture ?
akhithink analyse les failles de sécurité de ce code
akhithink conçois un système de cache distribué
```

### Ce qui se passe

1. **🌈 Animation Rainbow** : Le mot "AKHITHINK" s'affiche avec une animation arc-en-ciel (comme `ultrathink`)
2. **🧠 Réflexion Profonde** : Claudy active son mode d'analyse exhaustive
3. **📊 Analyse Multi-Dimensionnelle** :
   - Psychologique : sentiment utilisateur, charge cognitive
   - Technique : performance, complexité, coûts de rendu
   - Accessibilité : WCAG AAA, lecteurs d'écran
   - Scalabilité : maintenance long-terme, modularité
   - Sécurité : XSS, CSRF, injections, validation

### Format de Réponse AKHITHINK

```
⚡ AKHITHINK MODE ACTIVATED ⚡

1. Deep Reasoning Chain (analyse architecturale détaillée)
2. Edge Case Analysis (ce qui peut mal tourner)
3. Alternative Approaches (options considérées et rejetées)
4. The Code (solution optimisée et production-ready)
```

### Différence avec une question normale

| Mode Normal | Mode AKHITHINK |
|-------------|----------------|
| Réponse concise | Analyse exhaustive |
| Code direct | Justification profonde |
| 1-2 alternatives | Toutes les options explorées |
| Focus solution | Focus compréhension |

---

## Installation

### Étape 1 : Installer Node.js (si pas déjà fait)

Téléchargez et installez Node.js depuis : **https://nodejs.org/**

Choisissez la version **LTS** (recommandée).

### Étape 2 : Obtenir une clé API Z.AI

1. Allez sur **https://open.z.ai/**
2. Créez un compte ou connectez-vous
3. Allez dans la gestion des clés API
4. Créez une nouvelle clé et copiez-la

### Étape 3 : Installer Claudy

#### Windows - PowerShell (recommandé)

Ouvrez PowerShell et collez :
```powershell
irm https://raw.githubusercontent.com/uglyswap/Claudy/main/install.ps1 | iex
```

#### Windows - CMD (Invite de commandes)

Ouvrez CMD et collez :
```cmd
curl -fsSL https://raw.githubusercontent.com/uglyswap/Claudy/main/install.ps1 -o %TEMP%\install.ps1 && powershell -ExecutionPolicy Bypass -File %TEMP%\install.ps1
```

#### Mac / Linux

Ouvrez le Terminal et collez :
```bash
curl -fsSL https://raw.githubusercontent.com/uglyswap/Claudy/main/install.sh | bash
```

L'installateur vous demandera votre clé API Z.AI.

---

## Utilisation

Ouvrez n'importe quel terminal et tapez :

```
claudy
```

C'est tout !

**Fonctionne dans :** CMD, PowerShell, PowerShell Core, Terminal Windows, et tout terminal sur Mac/Linux.

---

## Désinstallation

### Windows - PowerShell

```powershell
irm https://raw.githubusercontent.com/uglyswap/Claudy/main/uninstall.ps1 | iex
```

### Windows - CMD

```cmd
curl -fsSL https://raw.githubusercontent.com/uglyswap/Claudy/main/uninstall.ps1 -o %TEMP%\uninstall.ps1 && powershell -ExecutionPolicy Bypass -File %TEMP%\uninstall.ps1
```

### Mac / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/uglyswap/Claudy/main/uninstall.sh | bash
```

Le désinstallateur supprime :
- ✅ Le dossier `~/.claudy/` (lib, bin, config, etc.)
- ✅ Les wrappers npm (`claudy.cmd`, `claudy.ps1`)
- ✅ L'entrée PATH pour `~/.claudy/bin`

**Claude Code n'est PAS touché** - seul Claudy est désinstallé.

---

## Architecture d'installation

### Comparaison Claudy vs Claude Code

| | Claudy | Claude Code CLI |
|---|--------|----------------|
| **Commande** | `claudy` | `claude` |
| **Installation** | `~/.claudy/lib/` (isolée) | npm global |
| **Config** | `~/.claudy/settings.json` | `~/.claude/settings.json` |
| **API** | Z.AI (GLM 4.7) | Anthropic |
| **Dépendances** | Isolées dans ~/.claudy/ | npm global |

### Indépendance totale

Les deux programmes ne partagent **aucun fichier** :

- **Claudy** a sa propre copie de `@anthropic-ai/claude-code` dans `~/.claudy/lib/`
- **Claude Code** utilise l'installation npm globale (si installé)
- Vous pouvez installer, désinstaller, ou modifier l'un sans affecter l'autre

---

## Serveurs MCP inclus

Ces serveurs sont automatiquement configurés pendant l'installation :

| Serveur | Fonction |
|---------|----------|
| **zai-vision** | Analyse d'images, vidéos, OCR, interprétation de diagrammes |
| **web-search-prime** | Recherche web en temps réel |
| **web-reader** | Lecture et extraction de contenu de pages web |

Tous utilisent votre clé API Z.AI. Rien à configurer.

---

## Configuration

La configuration de Claudy est stockée dans `~/.claudy/settings.json` :

- **Windows** : `C:\Users\VotreNom\.claudy\settings.json`
- **Mac/Linux** : `~/.claudy/settings.json`

### Modifier la clé API

#### Méthode 1 : Dans Claudy (recommandé)

Tapez directement dans Claudy :
```
/cle-api VOTRE_NOUVELLE_CLE
```

**Important** : Cette commande fonctionne **SANS utiliser le modèle**. Elle est interceptée par un hook et exécutée localement. Cela signifie :
- ✅ Fonctionne même si votre clé actuelle est invalide
- ✅ Pas de consommation de tokens
- ✅ Mise à jour instantanée des 4 emplacements

#### Méthode 2 : Au démarrage

Si votre clé est invalide ou manquante, Claudy vous demandera automatiquement une nouvelle clé au démarrage (avant de lancer le modèle).

#### Méthode 3 : Manuellement

Éditez `~/.claudy/settings.json` et remplacez toutes les occurrences de votre ancienne clé par la nouvelle (4 emplacements).

### Mode permissions

Par défaut, Claudy fonctionne en mode **bypass permissions** : il ne demande pas de confirmation pour les opérations sur les fichiers ou les commandes bash. C'est le mode recommandé pour une utilisation fluide.

Pour réactiver les confirmations, modifiez `~/.claudy/settings.json` :
```json
{
  "permissionMode": "default",
  "autoApprove": false
}
```

---

## FAQ

### Pourquoi "ANTHROPIC" dans les variables si on utilise Z.AI ?

Claude Code utilise ces noms de variables en interne. En changeant `ANTHROPIC_BASE_URL` vers Z.AI, toutes les requêtes sont redirigées vers GLM 4.7. Pas besoin de compte Anthropic.

### J'ai déjà Claude Code CLI installé, ça pose problème ?

**Non.** Claudy est 100% indépendant avec sa propre installation dans `~/.claudy/`. Les deux peuvent coexister sans conflit :
- `claude` → Claude Code CLI officiel (npm global + `~/.claude/`)
- `claudy` → Claudy avec GLM 4.7 (`~/.claudy/` uniquement)

### La commande claudy ne fonctionne pas ?

Après l'installation, **fermez et rouvrez votre terminal** pour que le PATH soit mis à jour. 

Sur Windows, vérifiez que `~/.claudy/bin/` est dans votre PATH :
```powershell
$env:PATH -split ';' | Select-String "claudy"
```

Sur Mac/Linux :
```bash
echo $PATH | tr ':' '\n' | grep claudy
```

### Comment tout désinstaller (Claudy + Claude Code) ?

Si vous voulez tout supprimer :
```bash
# Supprimer Claudy (installation isolée)
curl -fsSL https://raw.githubusercontent.com/uglyswap/Claudy/main/uninstall.sh | bash

# Supprimer Claude Code CLI (installation npm globale)
npm uninstall -g @anthropic-ai/claude-code
rm -rf ~/.claude
```

---

## Structure des fichiers

```
~/.claudy/
├── bin/
│   ├── claudy           # Wrapper (Linux/Mac)
│   ├── claudy.ps1       # Wrapper (Windows PowerShell)
│   ├── claudy.cmd       # Wrapper (Windows CMD)
│   └── claudy-logo.sh   # Script logo animé
├── hooks/
│   ├── cle-hook.ps1     # Hook /cle-api (Windows)
│   └── cle-hook.sh      # Hook /cle-api (Linux/Mac)
├── lib/
│   ├── package.json
│   └── node_modules/
│       └── @anthropic-ai/
│           └── claude-code/
│               ├── cli.js        # Original (non utilisé)
│               └── cli-claudy.js # Patché avec branding Claudy
├── modules/
│   └── Claudy-Logo.psm1 # Module PowerShell pour le logo
├── settings.json        # Configuration (API, MCP servers, hooks)
└── CLAUDE.md            # System prompt personnalisé
```

---

## En savoir plus

- **GLM 4.7** : Modèle d'IA développé par Zhipu AI
- **Z.AI** : Plateforme d'API pour GLM - https://open.z.ai/
- **Claude Code** : Outil de base développé par Anthropic
