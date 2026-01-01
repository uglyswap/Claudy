#!/usr/bin/env pwsh
# Claudy - Independent installation wrapper
# Uses ~/.claudy/ for EVERYTHING (config + code)
# Completely independent from Claude Code CLI

# Set terminal title to "claudy"
$Host.UI.RawUI.WindowTitle = "claudy"

$claudyDir = Join-Path $env:USERPROFILE ".claudy"
$claudyLibDir = Join-Path $claudyDir "lib"
$modulePath = Join-Path $claudyDir "modules\Claudy-Logo.psm1"
$settingsPath = Join-Path $claudyDir "settings.json"

# Check for --no-logo or -n flag
$showLogo = $true
$filteredArgs = @()
foreach ($arg in $args) {
    if ($arg -eq "--no-logo" -or $arg -eq "-n") {
        $showLogo = $false
    } else {
        $filteredArgs += $arg
    }
}

# Show animated logo if module exists and not disabled
if ($showLogo -and (Test-Path $modulePath)) {
    try {
        Import-Module $modulePath -Force -ErrorAction SilentlyContinue
        Claudy-Logo -Force
    } catch {
        # Silently continue if logo fails
    }
}

# ============================================
# API KEY VALIDATION AT STARTUP (SILENT)
# ============================================

function Test-ZaiApiKey {
    param([string]$Key)

    # Check for placeholder or empty key
    if (-not $Key -or $Key -eq "VOTRE_CLE_API_ZAI_ICI" -or $Key.Length -lt 10) {
        return $false
    }

    try {
        $headers = @{
            "Authorization" = "Bearer $Key"
            "Content-Type" = "application/json"
        }
        $body = '{"model":"glm-4.7","max_tokens":1,"messages":[{"role":"user","content":"test"}]}'

        $response = Invoke-RestMethod -Uri "https://api.z.ai/api/anthropic/v1/messages" `
            -Method POST -Headers $headers -Body $body -TimeoutSec 10 -ErrorAction Stop
        return $true
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        # 401/403 = key is definitely invalid
        if ($statusCode -eq 401 -or $statusCode -eq 403) {
            return $false
        }
        # Other errors (network, rate limit) = assume key is OK
        return $true
    }
}

function Update-ApiKeyInSettings {
    param([string]$NewKey, [string]$OldKey)

    try {
        $content = Get-Content $settingsPath -Raw -Encoding UTF8

        # Replace all occurrences of old key with new key
        $newContent = $content -replace [regex]::Escape($OldKey), $NewKey

        # Write back
        [System.IO.File]::WriteAllText($settingsPath, $newContent, [System.Text.UTF8Encoding]::new($true))

        return $true
    } catch {
        return $false
    }
}

function Prompt-ForNewApiKey {
    param([string]$Reason)

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "   CLE API Z.AI INVALIDE OU MANQUANTE  " -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Raison: $Reason" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Entrez votre nouvelle cle API Z.AI:" -ForegroundColor Cyan
    $newKey = Read-Host

    if (-not $newKey -or $newKey.Trim() -eq "") {
        Write-Host "[ERREUR] La cle ne peut pas etre vide." -ForegroundColor Red
        return $null
    }

    return $newKey.Trim()
}

# Read settings.json and get current API key
$apiKey = $null
if (Test-Path $settingsPath) {
    try {
        $settingsContent = Get-Content $settingsPath -Raw -Encoding UTF8
        $settings = $settingsContent | ConvertFrom-Json
        if ($settings.env -and $settings.env.ANTHROPIC_AUTH_TOKEN) {
            $apiKey = $settings.env.ANTHROPIC_AUTH_TOKEN
        }
    } catch {
        Write-Host "[WARN] Impossible de lire settings.json" -ForegroundColor Yellow
    }
}

# Check if API key exists and is valid (SILENT - no message)
$keyNeedsUpdate = $false
$updateReason = ""

if (-not $apiKey) {
    $keyNeedsUpdate = $true
    $updateReason = "Aucune cle API trouvee dans settings.json"
} elseif ($apiKey -eq "VOTRE_CLE_API_ZAI_ICI") {
    $keyNeedsUpdate = $true
    $updateReason = "Cle API placeholder detectee"
} else {
    # Test the API key silently
    $keyValid = Test-ZaiApiKey -Key $apiKey
    if (-not $keyValid) {
        $keyNeedsUpdate = $true
        $updateReason = "Cle API invalide ou expiree (erreur 401/403)"
    }
}

# If key needs update, prompt for new one
if ($keyNeedsUpdate) {
    $newKey = Prompt-ForNewApiKey -Reason $updateReason

    if ($newKey) {
        # Validate new key format (warning only)
        if (-not ($newKey -match "^[a-zA-Z0-9]+\.[a-zA-Z0-9]+$")) {
            Write-Host "[WARN] Le format de la cle semble inhabituel, mais on continue..." -ForegroundColor Yellow
        }

        # Update settings.json with new key in all 4 locations
        $oldKeyToReplace = if ($apiKey) { $apiKey } else { "VOTRE_CLE_API_ZAI_ICI" }
        $success = Update-ApiKeyInSettings -NewKey $newKey -OldKey $oldKeyToReplace

        if ($success) {
            Write-Host ""
            Write-Host "[OK] Cle API mise a jour dans les 4 emplacements" -ForegroundColor Green
            Write-Host ""

            # Update apiKey variable for env export
            $apiKey = $newKey
        } else {
            Write-Host "[ERREUR] Impossible de mettre a jour settings.json" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "[ERREUR] Cle API requise pour utiliser Claudy." -ForegroundColor Red
        exit 1
    }
}

# ============================================
# EXPORT ENVIRONMENT VARIABLES
# ============================================

if (Test-Path $settingsPath) {
    try {
        $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
        if ($settings.env) {
            $settings.env.PSObject.Properties | ForEach-Object {
                [Environment]::SetEnvironmentVariable($_.Name, $_.Value, "Process")
            }
        }
    } catch {
        Write-Host "[WARN] Impossible de lire settings.json" -ForegroundColor Yellow
    }
}

# Set config dir
$env:CLAUDE_CONFIG_DIR = $claudyDir

# Path to our isolated cli-claudy.js
$claudyExe = Join-Path $claudyLibDir "node_modules\@anthropic-ai\claude-code\cli-claudy.js"

# AUTO-REPAIR: If cli-claudy.js doesn't exist, recreate it
if (-not (Test-Path $claudyExe)) {
    Write-Host "[AUTO-REPAIR] cli-claudy.js manquant, re-creation en cours..." -ForegroundColor Yellow
    $patchUrl = "https://raw.githubusercontent.com/uglyswap/Claudy/main/patch-claudy-logo.js"
    $patchPath = Join-Path $env:TEMP "patch-claudy-logo.js"
    try {
        Invoke-WebRequest -Uri $patchUrl -OutFile $patchPath -UseBasicParsing -ErrorAction Stop
        $null = & node $patchPath $claudyLibDir 2>&1
        Remove-Item $patchPath -Force -ErrorAction SilentlyContinue
        Write-Host "[AUTO-REPAIR] cli-claudy.js recree avec succes" -ForegroundColor Green
    } catch {
        Write-Host "[WARN] Impossible de recreer cli-claudy.js: $_" -ForegroundColor Yellow
    }
}

# Fallback to cli.js if cli-claudy.js still doesn't exist
if (-not (Test-Path $claudyExe)) {
    $claudyExe = Join-Path $claudyLibDir "node_modules\@anthropic-ai\claude-code\cli.js"
}

if (Test-Path $claudyExe) {
    # Always add --dangerously-skip-permissions to bypass folder confirmation
    # Claudy trusts all directories by default (no "Do you want to work in this folder?" prompt)
    & node $claudyExe --dangerously-skip-permissions @filteredArgs
} else {
    Write-Host "[ERREUR] Claudy introuvable. Reinstallez avec:" -ForegroundColor Red
    Write-Host "irm https://raw.githubusercontent.com/uglyswap/Claudy/main/install.ps1 | iex" -ForegroundColor Yellow
    exit 1
}
