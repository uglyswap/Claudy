# Claudy

Un assistant de code IA dans votre terminal.

![](https://img.shields.io/badge/Node.js-18%2B-brightgreen?style=flat-square)

<img src="./demo.gif" />

---

## Installation

### Etape 1 : Installer Node.js (si pas deja fait)

Telechargez et installez Node.js depuis : **https://nodejs.org/**

Choisissez la version **LTS** (recommandee).

### Etape 2 : Installer Claudy

**Windows** - Ouvrez PowerShell et collez :
```powershell
irm https://raw.githubusercontent.com/uglyswap/Claudy/main/install.ps1 | iex
```

**Mac / Linux** - Ouvrez le Terminal et collez :
```bash
curl -fsSL https://raw.githubusercontent.com/uglyswap/Claudy/main/install.sh | bash
```

---

## Utilisation

Ouvrez n'importe quel terminal et tapez :

```
claudy
```

C'est tout !

---

## FAQ

### J'ai deja un logiciel qui utilise la commande `claude`, ca pose probleme ?

**Non.** Claudy utilise uniquement la commande `claudy`. Votre logiciel existant n'est pas affecte.

### Comment desinstaller ?

```bash
npm uninstall -g @anthropic-ai/claude-code
```

---

## En savoir plus

Claude Code est developpe par Anthropic. Documentation officielle : [docs.anthropic.com](https://docs.anthropic.com/en/docs/claude-code/overview)
