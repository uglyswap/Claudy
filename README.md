# Claudy

Un assistant de code IA dans votre terminal, propulsé par **GLM 4.7** (Z.AI).

**Pas besoin de compte Anthropic** - Claudy utilise l'API Z.AI.

![](https://img.shields.io/badge/Node.js-18%2B-brightgreen?style=flat-square)

<img src="./demo.gif" />

---

## Fonctionnalités

- **GLM 4.7** : Modèle d'IA puissant pour le code
- **Vision IA** : Analyse d'images, vidéos, OCR, diagrammes
- **Recherche web** : Recherche sur internet en temps réel
- **Lecture web** : Extraction du contenu de pages web
- **Mode sans permissions** : Pas de confirmations, Claudy travaille sans interruption
- **AKHITHINK** : Mode de réflexion profonde avec animation rainbow 🌈

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

## Coexistence avec Claude Code CLI

Claudy est **complètement isolé** de Claude Code CLI officiel :

| | Claudy | Claude Code CLI |
|---|--------|----------------|
| **Commande** | `claudy` | `claude` |
| **Config** | `~/.claudy/` | `~/.claude/` |
| **API** | Z.AI (GLM 4.7) | Anthropic |
| **CLI file** | `cli-claudy.js` | `cli.js` |

Vous pouvez installer et utiliser les deux en parallèle sans aucun conflit.

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

Utilisez la commande intégrée :
```
/cle-api <votre_nouvelle_cle>
```

Ou éditez le fichier et remplacez toutes les occurrences de votre ancienne clé par la nouvelle.

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

**Non.** Claudy utilise un dossier de configuration séparé (`~/.claudy/`) et une commande différente (`claudy`). Les deux peuvent coexister sans conflit :
- `claude` → Claude Code CLI officiel (utilise `~/.claude/` et `cli.js`)
- `claudy` → Claudy avec GLM 4.7 (utilise `~/.claudy/` et `cli-claudy.js`)

### La commande claudy ne fonctionne pas dans CMD ?

Après l'installation, **fermez et rouvrez votre terminal** pour que la commande soit reconnue. Si le problème persiste, vérifiez que le dossier npm est dans votre PATH :
```cmd
npm config get prefix
```
Le dossier retourné doit être dans votre variable d'environnement PATH.

### Comment désinstaller Claudy ?

**Étape 1** - Supprimer la commande claudy :
```bash
# Trouver où est installé claudy
npm root -g
# Supprimer les fichiers claudy dans le dossier bin npm
```

**Étape 2** - Supprimer le dossier de configuration :
```bash
# Mac/Linux
rm -rf ~/.claudy

# Windows (PowerShell)
Remove-Item -Recurse -Force $env:USERPROFILE\.claudy
```

**Note** : Cela ne désinstalle PAS Claude Code CLI ni n'affecte sa configuration dans `~/.claude/`.

### Comment désinstaller complètement (Claudy + Claude Code) ?

Si vous voulez tout supprimer :
```bash
# Désinstaller le package npm
npm uninstall -g @anthropic-ai/claude-code

# Supprimer les configurations
rm -rf ~/.claudy    # Config Claudy
rm -rf ~/.claude    # Config Claude Code CLI (si vous l'utilisez aussi)
```

---

## En savoir plus

- **GLM 4.7** : Modèle d'IA développé par Zhipu AI
- **Z.AI** : Plateforme d'API pour GLM - https://open.z.ai/
- **Claude Code** : Outil de base développé par Anthropic
