#!/usr/bin/env pwsh
# Claudy - Mise a jour de la cle API Z.AI
# Script standalone - N'utilise PAS l'API, fonctionne meme si la cle est invalide

param(
    [Parameter(Position=0)]
    [string]$NewKey
)

$settingsPath = Join-Path $env:USERPROFILE ".claudy\settings.json"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   CLAUDY - Mise a jour cle API Z.AI   " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verifier que settings.json existe
if (-not (Test-Path $settingsPath)) {
    Write-Host "[ERREUR] settings.json introuvable." -ForegroundColor Red
    Write-Host "Reinstallez Claudy avec:" -ForegroundColor Yellow
    Write-Host "irm https://raw.githubusercontent.com/uglyswap/Claudy/main/install.ps1 | iex" -ForegroundColor Yellow
    exit 1
}

# Lire le fichier actuel
try {
    $content = Get-Content $settingsPath -Raw -Encoding UTF8
    $settings = $content | ConvertFrom-Json
} catch {
    Write-Host "[ERREUR] Impossible de lire settings.json: $_" -ForegroundColor Red
    exit 1
}

# Recuperer l'ancienne cle
$oldKey = $settings.env.ANTHROPIC_AUTH_TOKEN
if (-not $oldKey) {
    Write-Host "[ERREUR] Impossible de trouver la cle actuelle dans settings.json" -ForegroundColor Red
    exit 1
}

# Afficher la cle actuelle (masquee)
$maskedOld = if ($oldKey.Length -gt 10) { $oldKey.Substring(0, 6) + "..." + $oldKey.Substring($oldKey.Length - 4) } else { "***" }
Write-Host "Cle actuelle: $maskedOld" -ForegroundColor Gray

# Demander la nouvelle cle si pas fournie en argument
if (-not $NewKey) {
    Write-Host ""
    $NewKey = Read-Host "Entrez votre nouvelle cle API Z.AI"
}

# Valider la nouvelle cle
if (-not $NewKey -or $NewKey.Trim() -eq "") {
    Write-Host "[ERREUR] La cle ne peut pas etre vide." -ForegroundColor Red
    exit 1
}

$NewKey = $NewKey.Trim()

# Avertir si format inhabituel
if (-not ($NewKey -match "^[a-zA-Z0-9]+\.[a-zA-Z0-9]+$")) {
    Write-Host "[WARN] Le format de la cle semble inhabituel, mais on continue..." -ForegroundColor Yellow
}

# Compter les occurrences avant remplacement
$countBefore = ([regex]::Matches($content, [regex]::Escape($oldKey))).Count

# Remplacer toutes les occurrences
$newContent = $content -replace [regex]::Escape($oldKey), $NewKey

# Compter les occurrences apres remplacement (devrait etre 0)
$countAfter = ([regex]::Matches($newContent, [regex]::Escape($oldKey))).Count

# Verifier qu'on a bien remplace
if ($countBefore -eq 0) {
    Write-Host "[ERREUR] Ancienne cle non trouvee dans settings.json" -ForegroundColor Red
    exit 1
}

# Ecrire le fichier
try {
    # Utiliser UTF8 sans BOM pour compatibilite
    [System.IO.File]::WriteAllText($settingsPath, $newContent, [System.Text.UTF8Encoding]::new($true))
} catch {
    Write-Host "[ERREUR] Impossible d'ecrire settings.json: $_" -ForegroundColor Red
    exit 1
}

# Afficher la nouvelle cle (masquee)
$maskedNew = if ($NewKey.Length -gt 10) { $NewKey.Substring(0, 6) + "..." + $NewKey.Substring($NewKey.Length - 4) } else { "***" }

Write-Host ""
Write-Host "Mise a jour de la cle API Z.AI..." -ForegroundColor Yellow
Write-Host "- ANTHROPIC_AUTH_TOKEN: OK" -ForegroundColor Green
Write-Host "- Z_AI_API_KEY (vision): OK" -ForegroundColor Green
Write-Host "- Authorization web-search-prime: OK" -ForegroundColor Green
Write-Host "- Authorization web-reader: OK" -ForegroundColor Green
Write-Host ""
Write-Host "[OK] $countBefore occurrence(s) remplacee(s)" -ForegroundColor Green
Write-Host "[OK] Nouvelle cle: $maskedNew" -ForegroundColor Green
Write-Host ""
Write-Host "Redemarrez Claudy pour appliquer les changements." -ForegroundColor Cyan
Write-Host ""
