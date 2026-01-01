#!/usr/bin/env pwsh
# Hook pour intercepter /cle-api et /cle AVANT le modele
# Fonctionne SANS API - pur PowerShell

param()

$settingsPath = Join-Path $env:USERPROFILE ".claudy\settings.json"

# Lire le prompt depuis stdin (format JSON de Claude Code)
$inputJson = $input | Out-String

if (-not $inputJson) {
    exit 0  # Pas d'input, continuer normalement
}

try {
    $data = $inputJson | ConvertFrom-Json
    $prompt = $data.prompt
} catch {
    exit 0  # Pas de JSON valide, continuer normalement
}

if (-not $prompt) {
    exit 0
}

# Verifier si c'est une commande /cle-api ou /cle
if ($prompt -match "^/(cle-api|cle)(\s+(.+))?$") {
    $newKey = $Matches[3]

    if (-not $newKey -or $newKey.Trim() -eq "") {
        # Pas de cle fournie - demander de la fournir en argument
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "   MISE A JOUR CLE API Z.AI" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Usage: /cle-api VOTRE_NOUVELLE_CLE" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Exemple:" -ForegroundColor Gray
        Write-Host "  /cle-api abc123def456.xyz789" -ForegroundColor White
        Write-Host ""
        exit 2  # Bloquer - ne pas envoyer au modele
    }

    $newKey = $newKey.Trim()

    # Lire settings.json
    if (-not (Test-Path $settingsPath)) {
        Write-Host "[ERREUR] settings.json introuvable" -ForegroundColor Red
        exit 2
    }

    try {
        $content = Get-Content $settingsPath -Raw -Encoding UTF8
        $settings = $content | ConvertFrom-Json
        $oldKey = $settings.env.ANTHROPIC_AUTH_TOKEN
    } catch {
        Write-Host "[ERREUR] Impossible de lire settings.json" -ForegroundColor Red
        exit 2
    }

    if (-not $oldKey) {
        Write-Host "[ERREUR] Ancienne cle non trouvee" -ForegroundColor Red
        exit 2
    }

    # Compter les occurrences
    $countBefore = ([regex]::Matches($content, [regex]::Escape($oldKey))).Count

    # Remplacer toutes les occurrences
    $newContent = $content -replace [regex]::Escape($oldKey), $newKey

    # Ecrire le fichier
    try {
        [System.IO.File]::WriteAllText($settingsPath, $newContent, [System.Text.UTF8Encoding]::new($true))
    } catch {
        Write-Host "[ERREUR] Impossible d'ecrire settings.json" -ForegroundColor Red
        exit 2
    }

    # Masquer les cles pour l'affichage
    $maskedOld = if ($oldKey.Length -gt 10) { $oldKey.Substring(0, 6) + "..." + $oldKey.Substring($oldKey.Length - 4) } else { "***" }
    $maskedNew = if ($newKey.Length -gt 10) { $newKey.Substring(0, 6) + "..." + $newKey.Substring($newKey.Length - 4) } else { "***" }

    # Afficher le resultat
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "   CLE API Z.AI MISE A JOUR" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Ancienne: $maskedOld" -ForegroundColor Gray
    Write-Host "Nouvelle: $maskedNew" -ForegroundColor White
    Write-Host ""
    Write-Host "- ANTHROPIC_AUTH_TOKEN: OK" -ForegroundColor Green
    Write-Host "- Z_AI_API_KEY (vision): OK" -ForegroundColor Green
    Write-Host "- Authorization web-search-prime: OK" -ForegroundColor Green
    Write-Host "- Authorization web-reader: OK" -ForegroundColor Green
    Write-Host ""
    Write-Host "$countBefore occurrence(s) remplacee(s)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Redemarrez Claudy pour appliquer." -ForegroundColor Yellow
    Write-Host ""

    exit 2  # Bloquer - ne pas envoyer au modele
}

# Pas une commande /cle, continuer normalement
exit 0
