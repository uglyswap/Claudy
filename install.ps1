#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Installs Claudy with GLM 4.7 (Z.AI), MCP servers, ASCII logo, and Frontend Master prompt.
    Claudy is installed separately from Claude Code CLI - both can coexist.

.EXAMPLE
    PowerShell / PowerShell Core:
    irm https://raw.githubusercontent.com/uglyswap/Claudy/main/install.ps1 | iex

    CMD (Invite de commandes):
    curl -fsSL https://raw.githubusercontent.com/uglyswap/Claudy/main/install.ps1 -o %TEMP%\install.ps1 && powershell -ExecutionPolicy Bypass -File %TEMP%\install.ps1
#>

$ErrorActionPreference = "Stop"

# Version figee pour eviter les breaking changes d'Anthropic
$CLAUDE_CODE_VERSION = "2.0.74"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "         CLAUDY INSTALLER              " -ForegroundColor Cyan
Write-Host "       Powered by GLM 4.7 (Z.AI)       " -ForegroundColor Cyan
Write-Host "   Claude Code v$CLAUDE_CODE_VERSION (frozen)    " -ForegroundColor Gray
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Node.js is installed
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "[ERREUR] Node.js n'est pas installe." -ForegroundColor Red
    Write-Host ""
    Write-Host "Telechargez Node.js ici : https://nodejs.org/" -ForegroundColor Yellow
    Write-Host "Choisissez la version LTS (recommandee)." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

$nodeVersion = (node --version) -replace 'v', ''
$nodeMajor = [int]($nodeVersion.Split('.')[0])
if ($nodeMajor -lt 18) {
    Write-Host "[ERREUR] Node.js 18 ou superieur est requis." -ForegroundColor Red
    Write-Host "Version actuelle : $nodeVersion" -ForegroundColor Red
    Write-Host ""
    Write-Host "Telechargez la derniere version : https://nodejs.org/" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}
Write-Host "[OK] Node.js $nodeVersion" -ForegroundColor Green

# Check if npm is installed
if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Host "[ERREUR] npm n'est pas installe." -ForegroundColor Red
    exit 1
}
Write-Host "[OK] npm" -ForegroundColor Green

# Get npm global path
$npmPrefix = npm config get prefix
$npmRoot = npm root -g

Write-Host ""
Write-Host "Installation de Claude Code v$CLAUDE_CODE_VERSION..." -ForegroundColor Yellow

# Install claude-code with pinned version
npm install -g "@anthropic-ai/claude-code@$CLAUDE_CODE_VERSION" 2>&1 | Out-Null

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERREUR] Echec de l'installation." -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Claude Code v$CLAUDE_CODE_VERSION installe" -ForegroundColor Green

# ============================================
# CREATE CLI-CLAUDY.JS WITH CLAUDY BRANDING
# ============================================
Write-Host "Creation de cli-claudy.js avec branding Claudy..." -ForegroundColor Yellow

# Download and run the patch script (creates cli-claudy.js, does NOT modify cli.js)
$patchScriptUrl = "https://raw.githubusercontent.com/uglyswap/Claudy/main/patch-claudy-logo.js"
$patchScriptPath = Join-Path $env:TEMP "patch-claudy-logo.js"

try {
    Invoke-WebRequest -Uri $patchScriptUrl -OutFile $patchScriptPath -UseBasicParsing
    $patchResult = & node $patchScriptPath 2>&1
    Write-Host $patchResult
    Write-Host "[OK] cli-claudy.js cree avec logo CLAUDY" -ForegroundColor Magenta
} catch {
    Write-Host "[WARN] Impossible de creer cli-claudy.js: $_" -ForegroundColor Yellow
}
finally {
    if (Test-Path $patchScriptPath) {
        Remove-Item $patchScriptPath -Force -ErrorAction SilentlyContinue
    }
}

# Create .claudy directory (separate from .claude to allow coexistence)
$claudyDir = Join-Path $env:USERPROFILE ".claudy"
if (-not (Test-Path $claudyDir)) {
    New-Item -ItemType Directory -Path $claudyDir -Force | Out-Null
}

# Create modules directory
$modulesDir = Join-Path $claudyDir "modules"
if (-not (Test-Path $modulesDir)) {
    New-Item -ItemType Directory -Path $modulesDir -Force | Out-Null
}

# Download and install Claudy-Logo module (for wrapper animation)
Write-Host "Installation du module Claudy-Logo..." -ForegroundColor Yellow
$logoModuleUrl = "https://raw.githubusercontent.com/uglyswap/Claudy/main/Claudy-Logo.psm1"
$logoModulePath = Join-Path $modulesDir "Claudy-Logo.psm1"
try {
    Invoke-WebRequest -Uri $logoModuleUrl -OutFile $logoModulePath -UseBasicParsing
    Write-Host "[OK] Module Claudy-Logo installe" -ForegroundColor Green
} catch {
    Write-Host "[WARN] Impossible de telecharger le module logo" -ForegroundColor Yellow
}

# Create claudy wrapper script that shows logo then launches cli-claudy.js
# INCLUDES AUTO-REPAIR: If cli-claudy.js is missing, it re-downloads and runs the patch
$claudyWrapperPath = Join-Path $npmPrefix "claudy.ps1"
$claudyWrapperContent = @'
#!/usr/bin/env pwsh
# Claudy - Wrapper for Claude Code with custom logo
# Uses ~/.claudy/ for config (separate from Claude Code CLI's ~/.claude/)
# IMPORTANT: Uses cli-claudy.js (patched) instead of cli.js (original)
# AUTO-REPAIR: If cli-claudy.js is missing (e.g., after npm update), it recreates it

# Set terminal title to "claudy"
$Host.UI.RawUI.WindowTitle = "claudy"

$claudyDir = Join-Path $env:USERPROFILE ".claudy"
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

# CRITICAL FIX: Read settings.json and export env vars directly
# CLAUDE_CONFIG_DIR is NOT respected by Claude Code 2.0.74
if (Test-Path $settingsPath) {
    try {
        $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
        if ($settings.env) {
            # Export each environment variable from settings.json
            $settings.env.PSObject.Properties | ForEach-Object {
                [Environment]::SetEnvironmentVariable($_.Name, $_.Value, "Process")
            }
        }
    } catch {
        Write-Host "[WARN] Impossible de lire settings.json" -ForegroundColor Yellow
    }
}

# Also set CLAUDE_CONFIG_DIR just in case future versions support it
$env:CLAUDE_CONFIG_DIR = $claudyDir

# Get the directory where this script is located
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Find cli-claudy.js (patched version with Claudy branding)
$npmRoot = npm root -g 2>$null
$claudyExe = $null

# Try to find cli-claudy.js
$possiblePaths = @(
    (Join-Path $scriptDir "node_modules\@anthropic-ai\claude-code\cli-claudy.js"),
    (Join-Path $npmRoot "@anthropic-ai\claude-code\cli-claudy.js")
)

foreach ($path in $possiblePaths) {
    if ($path -and (Test-Path $path)) {
        $claudyExe = $path
        break
    }
}

# AUTO-REPAIR: If cli-claudy.js doesn't exist, recreate it by running the patch
if (-not $claudyExe -or -not (Test-Path $claudyExe)) {
    Write-Host "[AUTO-REPAIR] cli-claudy.js manquant, re-creation en cours..." -ForegroundColor Yellow
    $patchUrl = "https://raw.githubusercontent.com/uglyswap/Claudy/main/patch-claudy-logo.js"
    $patchPath = Join-Path $env:TEMP "patch-claudy-logo.js"
    try {
        Invoke-WebRequest -Uri $patchUrl -OutFile $patchPath -UseBasicParsing -ErrorAction Stop
        $null = & node $patchPath 2>&1
        Remove-Item $patchPath -Force -ErrorAction SilentlyContinue
        Write-Host "[AUTO-REPAIR] cli-claudy.js recree avec succes" -ForegroundColor Green
        
        # Try to find it again after patch
        foreach ($path in $possiblePaths) {
            if ($path -and (Test-Path $path)) {
                $claudyExe = $path
                break
            }
        }
    } catch {
        Write-Host "[WARN] Impossible de recreer cli-claudy.js: $_" -ForegroundColor Yellow
    }
}

# Final fallback to cli.js if cli-claudy.js still doesn't exist
if (-not $claudyExe -or -not (Test-Path $claudyExe)) {
    $fallbackPaths = @(
        (Join-Path $scriptDir "node_modules\@anthropic-ai\claude-code\cli.js"),
        (Join-Path $npmRoot "@anthropic-ai\claude-code\cli.js")
    )
    foreach ($path in $fallbackPaths) {
        if ($path -and (Test-Path $path)) {
            $claudyExe = $path
            break
        }
    }
}

if ($claudyExe -and (Test-Path $claudyExe)) {
    & node $claudyExe @filteredArgs
} else {
    Write-Host "[ERREUR] Claude Code introuvable" -ForegroundColor Red
    exit 1
}
'@

$claudyWrapperContent | Out-File -FilePath $claudyWrapperPath -Encoding utf8 -Force
Write-Host "[OK] Wrapper Claudy cree (avec auto-reparation)" -ForegroundColor Green

# Create batch file for cmd.exe compatibility
# This works with both pwsh (PowerShell Core) and powershell (Windows PowerShell)
$claudyCmdPath = Join-Path $npmPrefix "claudy.cmd"
$claudyCmdContent = @"
@echo off
title claudy
REM Try PowerShell Core (pwsh) first, fall back to Windows PowerShell
where pwsh >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    pwsh -NoProfile -ExecutionPolicy Bypass -File "%~dp0claudy.ps1" %*
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0claudy.ps1" %*
)
"@
$claudyCmdContent | Out-File -FilePath $claudyCmdPath -Encoding ascii -Force
Write-Host "[OK] Commande 'claudy' creee (CMD + PowerShell)" -ForegroundColor Green

# NOTE: We do NOT touch the 'claude' command
# It uses the original cli.js (not patched)
Write-Host "[OK] Commande 'claude' preservee (utilise cli.js original)" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "     CONFIGURATION GLM 4.7 (Z.AI)      " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Pour utiliser Claudy, vous avez besoin d'une cle API Z.AI." -ForegroundColor White
Write-Host ""
Write-Host "Si vous n'en avez pas encore :" -ForegroundColor Yellow
Write-Host "  1. Allez sur https://open.z.ai/" -ForegroundColor Yellow
Write-Host "  2. Creez un compte ou connectez-vous" -ForegroundColor Yellow
Write-Host "  3. Allez dans la gestion des cles API" -ForegroundColor Yellow
Write-Host "  4. Creez une nouvelle cle" -ForegroundColor Yellow
Write-Host ""

$apiKey = Read-Host "Entrez votre cle API Z.AI (ou appuyez sur Entree pour configurer plus tard)"

$settingsPath = Join-Path $claudyDir "settings.json"

$keyConfigured = $true
if ([string]::IsNullOrWhiteSpace($apiKey)) {
    $apiKey = "VOTRE_CLE_API_ZAI_ICI"
    $keyConfigured = $false
    Write-Host ""
    Write-Host "[INFO] Configuration creee sans cle API." -ForegroundColor Yellow
    Write-Host "       Editez le fichier suivant pour ajouter votre cle :" -ForegroundColor Yellow
    Write-Host "       $settingsPath" -ForegroundColor Cyan
}

# Create settings.json with GLM config, MCP servers, and bypass permissions
$settingsContent = @"
{
  "permissionMode": "bypassPermissions",
  "confirmations": {
    "fileOperations": false,
    "bashCommands": false,
    "toolUse": false
  },
  "autoApprove": true,
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "$apiKey",
    "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic",
    "API_TIMEOUT_MS": "3000000",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "glm-4.7",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "glm-4.7",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "glm-4.7",
    "DISABLE_AUTOUPDATER": "1"
  },
  "mcpServers": {
    "zai-vision": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@z_ai/mcp-server"],
      "env": {
        "Z_AI_API_KEY": "$apiKey",
        "Z_AI_MODE": "ZAI"
      }
    },
    "web-search-prime": {
      "type": "http",
      "url": "https://api.z.ai/api/mcp/web_search_prime/mcp",
      "headers": {
        "Authorization": "Bearer $apiKey"
      }
    },
    "web-reader": {
      "type": "http",
      "url": "https://api.z.ai/api/mcp/web_reader/mcp",
      "headers": {
        "Authorization": "Bearer $apiKey"
      }
    }
  }
}
"@

$settingsContent | Out-File -FilePath $settingsPath -Encoding utf8 -Force
Write-Host "[OK] Configuration GLM 4.7 creee" -ForegroundColor Green
Write-Host "[OK] Mode bypass permissions active" -ForegroundColor Green
Write-Host "[OK] Auto-updater desactive" -ForegroundColor Green
Write-Host "[OK] 3 serveurs MCP configures" -ForegroundColor Green

# Download CLAUDE.md from GitHub instead of hardcoding
$claudeMdPath = Join-Path $claudyDir "CLAUDE.md"
$claudeMdUrl = "https://raw.githubusercontent.com/uglyswap/Claudy/main/CLAUDE.md"

try {
    Invoke-WebRequest -Uri $claudeMdUrl -OutFile $claudeMdPath -UseBasicParsing
    Write-Host "[OK] System prompt AKHITHINK installe" -ForegroundColor Magenta
    Write-Host "[OK] Identite Claudy Focan configuree" -ForegroundColor Magenta
} catch {
    Write-Host "[WARN] Impossible de telecharger CLAUDE.md" -ForegroundColor Yellow
}

# ============================================
# INSTALL CLAUDY SKILLS
# ============================================
Write-Host ""
Write-Host "Installation des skills Claudy..." -ForegroundColor Yellow

# Create skills directory in ~/.claudy/skills/ (Claudy's config directory)
# Also install in ~/.claude/skills/ for compatibility
$skillsDirs = @(
    (Join-Path $claudyDir "skills"),
    (Join-Path $env:USERPROFILE ".claude\skills")
)

foreach ($skillsDir in $skillsDirs) {
    if (-not (Test-Path $skillsDir)) {
        New-Item -ItemType Directory -Path $skillsDir -Force | Out-Null
    }
    
    # Install /cle-api skill for changing Z.AI API key
    $cleApiSkillDir = Join-Path $skillsDir "cle-api"
    if (-not (Test-Path $cleApiSkillDir)) {
        New-Item -ItemType Directory -Path $cleApiSkillDir -Force | Out-Null
    }
    
    $cleApiSkillUrl = "https://raw.githubusercontent.com/uglyswap/Claudy/main/skills/cle-api/SKILL.md"
    $cleApiSkillPath = Join-Path $cleApiSkillDir "SKILL.md"
    
    try {
        Invoke-WebRequest -Uri $cleApiSkillUrl -OutFile $cleApiSkillPath -UseBasicParsing
    } catch {
        # Silent fail for secondary location
    }
}

Write-Host "[OK] Skill /cle-api installe (changer la cle API)" -ForegroundColor Magenta

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "      INSTALLATION TERMINEE !          " -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Pour utiliser Claudy, tapez simplement :" -ForegroundColor White
Write-Host ""
Write-Host "    claudy" -ForegroundColor Cyan
Write-Host ""
Write-Host "Fonctionne dans : CMD, PowerShell, Terminal Windows" -ForegroundColor Gray
Write-Host ""
Write-Host "Options du logo anime:" -ForegroundColor White
Write-Host "    claudy --no-logo    Desactive le logo anime" -ForegroundColor Gray
Write-Host "    claudy -n           Raccourci pour --no-logo" -ForegroundColor Gray
Write-Host ""
if (-not $keyConfigured) {
    Write-Host "N'oubliez pas d'ajouter votre cle API Z.AI dans :" -ForegroundColor Yellow
    Write-Host "    $settingsPath" -ForegroundColor Cyan
    Write-Host ""
}
Write-Host "Coexistence avec Claude Code CLI :" -ForegroundColor White
Write-Host "  - 'claudy' utilise cli-claudy.js (patche)" -ForegroundColor Gray
Write-Host "  - 'claude' utilise cli.js (original, non modifie)" -ForegroundColor Gray
Write-Host "  - Les deux peuvent fonctionner en parallele" -ForegroundColor Gray
Write-Host "  - Mise a jour Claude Code? Claudy se repare automatiquement!" -ForegroundColor Gray
Write-Host ""
Write-Host "Fonctionnalites incluses :" -ForegroundColor White
Write-Host "  - Logo CLAUDY avec degrade jaune-magenta" -ForegroundColor Magenta
Write-Host "  - GLM 4.7 (pas besoin de compte Anthropic)" -ForegroundColor Green
Write-Host "  - Vision IA (images, videos, OCR)" -ForegroundColor Green
Write-Host "  - Recherche web" -ForegroundColor Green
Write-Host "  - Lecture de pages web" -ForegroundColor Green
Write-Host "  - Mode sans permissions (pas de confirmations)" -ForegroundColor Green
Write-Host "  - Version figee (pas de mises a jour auto)" -ForegroundColor Green
Write-Host "  - AKHITHINK: Deep reasoning mode" -ForegroundColor Magenta
Write-Host "  - Identite Claudy Focan (Dikkenek)" -ForegroundColor Magenta
Write-Host ""
Write-Host "Commandes speciales :" -ForegroundColor White
Write-Host "  - /cle-api <nouvelle_cle>  Changer la cle API Z.AI" -ForegroundColor Cyan
Write-Host ""
Write-Host "Version Claude Code: $CLAUDE_CODE_VERSION (frozen)" -ForegroundColor Gray
Write-Host ""
