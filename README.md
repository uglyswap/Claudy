# Claudy

Un assistant de code IA dans votre terminal, propulse par **GLM 4.7** (Z.AI).

**Pas besoin de compte Anthropic** - Claudy utilise l'API Z.AI.

![](https://img.shields.io/badge/Node.js-18%2B-brightgreen?style=flat-square)

<img src="./demo.gif" />

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

## Configuration

La configuration est stockee dans `~/.claude/settings.json` :

```json
{
    "env": {
        "ANTHROPIC_AUTH_TOKEN": "votre_cle_api_zai",
        "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic",
        "API_TIMEOUT_MS": "3000000"
    }
}
```

### Modifier la cle API

Editez le fichier `~/.claude/settings.json` et remplacez la valeur de `ANTHROPIC_AUTH_TOKEN` par votre cle.

- **Windows** : `C:\Users\VotreNom\.claude\settings.json`
- **Mac/Linux** : `~/.claude/settings.json`

---

## FAQ

### Pourquoi "ANTHROPIC" dans les variables si on utilise Z.AI ?

Claude Code utilise ces noms de variables en interne. En changeant `ANTHROPIC_BASE_URL` vers Z.AI, toutes les requetes sont redirigees vers GLM 4.7. Pas besoin de compte Anthropic.

### J'ai deja un logiciel qui utilise la commande `claude`, ca pose probleme ?

**Non.** Claudy utilise uniquement la commande `claudy`. Votre logiciel existant n'est pas affecte.

### Comment desinstaller ?

```bash
npm uninstall -g @anthropic-ai/claude-code
```

Puis supprimez le dossier `~/.claude` si vous le souhaitez.

---

## En savoir plus

- **GLM 4.7** : Modele d'IA developpe par Zhipu AI
- **Z.AI** : Plateforme d'API pour GLM - https://open.z.ai/
- **Claude Code** : Outil de base developpe par Anthropic
