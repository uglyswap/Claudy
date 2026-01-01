---
name: cle-api
description: Met a jour la cle API Z.AI dans tous les emplacements (modele principal, vision IA, recherche web, lecture web). Utiliser quand l'utilisateur veut changer sa cle API Z.AI avec /cle-api ou /cle.
user-invocable: true
---

# Skill: Mise a jour de la cle API Z.AI

## Declencheurs
- `/cle-api`
- `/cle-api <nouvelle_cle>`
- `/cle`
- `/cle <nouvelle_cle>`

## Instructions

Quand l'utilisateur invoque ce skill:

### 1. Obtenir la nouvelle cle API

- Si l'utilisateur a fourni une cle en argument (ex: `/cle-api abc123`), utiliser cette cle
- Sinon, demander a l'utilisateur de fournir sa nouvelle cle API Z.AI

### 2. Valider le format de la cle

La cle Z.AI a generalement ce format: `xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.xxxxxxxxxxxxxx`
- Verifier que la cle n'est pas vide
- Avertir si le format semble inhabituel (mais continuer quand meme)

### 3. Lire le fichier settings.json

Chemin: `~/.claudy/settings.json`

```bash
cat "$HOME/.claudy/settings.json"
```

### 4. Mettre a jour les 4 emplacements de la cle API

La cle apparait a 4 endroits dans settings.json:

1. `env.ANTHROPIC_AUTH_TOKEN` - Modele principal GLM 4.7
2. `mcpServers.zai-vision.env.Z_AI_API_KEY` - Vision IA (images, videos, OCR)
3. `mcpServers.web-search-prime.headers.Authorization` - Recherche web (format: "Bearer <cle>")
4. `mcpServers.web-reader.headers.Authorization` - Lecture de pages web (format: "Bearer <cle>")

### 5. Ecrire le fichier mis a jour

Utiliser une commande PowerShell pour remplacer toutes les occurrences:

```powershell
$settingsPath = "$env:USERPROFILE\.claudy\settings.json"
$oldKey = "<ANCIENNE_CLE>"
$newKey = "<NOUVELLE_CLE>"

$content = Get-Content $settingsPath -Raw
$content = $content -replace [regex]::Escape($oldKey), $newKey
Set-Content $settingsPath $content -NoNewline
```

OU avec sed sur Linux/Mac:
```bash
sed -i "s/$OLD_KEY/$NEW_KEY/g" ~/.claudy/settings.json
```

### 6. Confirmer la mise a jour

Afficher un message de confirmation:
- Nombre d'occurrences remplacees (devrait etre 4)
- Rappeler a l'utilisateur de redemarrer Claudy pour que les changements prennent effet

## Exemple d'execution

```
Utilisateur: /cle-api ma_nouvelle_cle_ici

Claude: Mise a jour de la cle API Z.AI...
- ANTHROPIC_AUTH_TOKEN: OK
- Z_AI_API_KEY (vision): OK
- Authorization web-search-prime: OK
- Authorization web-reader: OK

Cle API mise a jour avec succes dans les 4 emplacements.
Redemarrez Claudy pour appliquer les changements.
```

## Notes importantes

- TOUJOURS lire le fichier settings.json d'abord pour recuperer l'ancienne cle
- JAMAIS afficher la cle complete dans les logs (masquer avec des asterisques)
- Si le fichier settings.json n'existe pas, informer l'utilisateur de reinstaller Claudy
- La cle doit etre la meme dans les 4 emplacements pour que tous les services fonctionnent
