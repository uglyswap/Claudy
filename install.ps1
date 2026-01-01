#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Installs Claudy with GLM 4.7 (Z.AI), MCP servers, ASCII logo, and Frontend Master prompt.
    Claudy is installed INDEPENDENTLY from Claude Code CLI - completely separate installations.

.DESCRIPTION
    Claudy has its own isolated installation in ~/.claudy/lib/
    This means:
    - Uninstalling Claude Code does NOT affect Claudy
    - Updating Claude Code does NOT affect Claudy
    - Both programs are 100% independent

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
Write-Host "      INSTALLATION INDEPENDANTE        " -ForegroundColor Yellow
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

# ============================================
# CREATE ISOLATED CLAUDY INSTALLATION
# ============================================
$claudyDir = Join-Path $env:USERPROFILE ".claudy"
$claudyLibDir = Join-Path $claudyDir "lib"
$claudyBinDir = Join-Path $claudyDir "bin"
$claudyModulesDir = Join-Path $claudyDir "modules"

# Create directories
foreach ($dir in @($claudyDir, $claudyLibDir, $claudyBinDir, $claudyModulesDir)) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

Write-Host ""
Write-Host "Installation de Claude Code v$CLAUDE_CODE_VERSION dans ~/.claudy/lib/..." -ForegroundColor Yellow
Write-Host "(Installation isolee, independante de npm global)" -ForegroundColor Gray

# Initialize package.json in lib directory if not exists
$packageJsonPath = Join-Path $claudyLibDir "package.json"
if (-not (Test-Path $packageJsonPath)) {
    $packageJson = @{
        name = "claudy-local"
        version = "1.0.0"
        description = "Claudy isolated installation"
        private = $true
    } | ConvertTo-Json
    $packageJson | Out-File -FilePath $packageJsonPath -Encoding utf8 -Force
}

# Install claude-code locally in ~/.claudy/lib/
Push-Location $claudyLibDir
try {
    npm install "@anthropic-ai/claude-code@$CLAUDE_CODE_VERSION" 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "npm install failed"
    }
} catch {
    Write-Host "[ERREUR] Echec de l'installation: $_" -ForegroundColor Red
    Pop-Location
    exit 1
}
Pop-Location

Write-Host "[OK] Claude Code v$CLAUDE_CODE_VERSION installe dans ~/.claudy/lib/" -ForegroundColor Green

# ============================================
# CREATE CLI-CLAUDY.JS WITH CLAUDY BRANDING
# ============================================
Write-Host "Creation de cli-claudy.js avec branding Claudy..." -ForegroundColor Yellow

# The CLI path in our isolated installation
$cliSourcePath = Join-Path $claudyLibDir "node_modules\@anthropic-ai\claude-code\cli.js"
$cliClaudyPath = Join-Path $claudyLibDir "node_modules\@anthropic-ai\claude-code\cli-claudy.js"

# Download and run the patch script with the local path
$patchScriptUrl = "https://raw.githubusercontent.com/uglyswap/Claudy/main/patch-claudy-logo.js"
$patchScriptPath = Join-Path $env:TEMP "patch-claudy-logo.js"

try {
    Invoke-WebRequest -Uri $patchScriptUrl -OutFile $patchScriptPath -UseBasicParsing
    # Pass the local installation path as argument
    $patchResult = & node $patchScriptPath $claudyLibDir 2>&1
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

# Download and install Claudy-Logo module (for wrapper animation)
Write-Host "Installation du module Claudy-Logo..." -ForegroundColor Yellow
$logoModuleUrl = "https://raw.githubusercontent.com/uglyswap/Claudy/main/Claudy-Logo.psm1"
$logoModulePath = Join-Path $claudyModulesDir "Claudy-Logo.psm1"
try {
    Invoke-WebRequest -Uri $logoModuleUrl -OutFile $logoModulePath -UseBasicParsing
    Write-Host "[OK] Module Claudy-Logo installe" -ForegroundColor Green
} catch {
    Write-Host "[WARN] Impossible de telecharger le module logo" -ForegroundColor Yellow
}

# ============================================
# DOWNLOAD CLAUDY WRAPPER SCRIPTS FROM GITHUB
# ============================================
Write-Host "Telechargement des scripts Claudy..." -ForegroundColor Yellow

# Download claudy.ps1 (main wrapper with API key validation)
$claudyPs1Url = "https://raw.githubusercontent.com/uglyswap/Claudy/main/bin/claudy.ps1"
$claudyPs1Path = Join-Path $claudyBinDir "claudy.ps1"
try {
    Invoke-WebRequest -Uri $claudyPs1Url -OutFile $claudyPs1Path -UseBasicParsing
    Write-Host "[OK] claudy.ps1 telecharge" -ForegroundColor Green
} catch {
    Write-Host "[WARN] Impossible de telecharger claudy.ps1" -ForegroundColor Yellow
}

# Create batch file in ~/.claudy/bin/
$claudyCmdPath = Join-Path $claudyBinDir "claudy.cmd"
$claudyCmdContent = @"
@echo off
title claudy
REM Claudy - Independent installation
REM Try PowerShell Core (pwsh) first, fall back to Windows PowerShell
where pwsh >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    pwsh -NoProfile -ExecutionPolicy Bypass -File "%USERPROFILE%\.claudy\bin\claudy.ps1" %*
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%USERPROFILE%\.claudy\bin\claudy.ps1" %*
)
"@
$claudyCmdContent | Out-File -FilePath $claudyCmdPath -Encoding ascii -Force

Write-Host "[OK] Wrappers Claudy crees dans ~/.claudy/bin/" -ForegroundColor Green

# ============================================
# ADD CLAUDY TO PATH
# ============================================
Write-Host "Configuration du PATH..." -ForegroundColor Yellow

$userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($userPath -notlike "*$claudyBinDir*") {
    $newPath = "$claudyBinDir;$userPath"
    [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
    Write-Host "[OK] ~/.claudy/bin/ ajoute au PATH utilisateur" -ForegroundColor Green
    Write-Host "[INFO] Redemarrez votre terminal pour que le PATH soit pris en compte" -ForegroundColor Yellow
} else {
    Write-Host "[OK] ~/.claudy/bin/ deja dans le PATH" -ForegroundColor Green
}

# Also add to current session
$env:PATH = "$claudyBinDir;$env:PATH"

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
    Write-Host "       Au demarrage de Claudy, il vous demandera votre cle." -ForegroundColor Yellow
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

# Download CLAUDE.md from GitHub
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

# Create skills directory in ~/.claudy/skills/
$skillsDir = Join-Path $claudyDir "skills"
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
    Write-Host "[OK] Skill /cle-api installe" -ForegroundColor Magenta
} catch {
    Write-Host "[WARN] Impossible d'installer le skill /cle-api" -ForegroundColor Yellow
}

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
    Write-Host "Au premier demarrage, Claudy vous demandera votre cle API Z.AI." -ForegroundColor Yellow
    Write-Host ""
}
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "       INDEPENDANCE TOTALE             " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Claudy est 100% independant de Claude Code :" -ForegroundColor White
Write-Host "  - Installation isolee : ~/.claudy/lib/" -ForegroundColor Gray
Write-Host "  - Configuration isolee : ~/.claudy/settings.json" -ForegroundColor Gray
Write-Host "  - Binaires isoles : ~/.claudy/bin/" -ForegroundColor Gray
Write-Host ""
Write-Host "Fonctionnalites incluses :" -ForegroundColor White
Write-Host "  - Logo CLAUDY avec degrade jaune-magenta" -ForegroundColor Magenta
Write-Host "  - GLM 4.7 (pas besoin de compte Anthropic)" -ForegroundColor Green
Write-Host "  - Vision IA (images, videos, OCR)" -ForegroundColor Green
Write-Host "  - Recherche web" -ForegroundColor Green
Write-Host "  - Lecture de pages web" -ForegroundColor Green
Write-Host "  - Mode sans permissions (pas de confirmations)" -ForegroundColor Green
Write-Host "  - Version figee $CLAUDE_CODE_VERSION (pas de mises a jour auto)" -ForegroundColor Green
Write-Host "  - AKHITHINK: Deep reasoning mode" -ForegroundColor Magenta
Write-Host "  - Identite Claudy Focan (Dikkenek)" -ForegroundColor Magenta
Write-Host ""
Write-Host "Gestion de la cle API :" -ForegroundColor White
Write-Host "  - Au demarrage: si cle invalide, Claudy demande une nouvelle" -ForegroundColor Cyan
Write-Host "  - Dans Claudy: /cle-api pour changer la cle" -ForegroundColor Cyan
Write-Host ""
Write-Host "Structure d'installation :" -ForegroundColor Gray
Write-Host "  ~/.claudy/" -ForegroundColor DarkGray
Write-Host "    +-- bin/           (claudy)" -ForegroundColor DarkGray
Write-Host "    +-- lib/           (node_modules isoles)" -ForegroundColor DarkGray
Write-Host "    +-- modules/       (Claudy-Logo.psm1)" -ForegroundColor DarkGray
Write-Host "    +-- skills/        (skills Claudy)" -ForegroundColor DarkGray
Write-Host "    +-- settings.json  (configuration)" -ForegroundColor DarkGray
Write-Host "    +-- CLAUDE.md      (system prompt)" -ForegroundColor DarkGray
Write-Host ""
