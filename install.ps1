#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Installs Claudy with GLM 4.7 (Z.AI) and MCP servers.

.EXAMPLE
    irm https://raw.githubusercontent.com/uglyswap/Claudy/main/install.ps1 | iex
#>

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "         CLAUDY INSTALLER              " -ForegroundColor Cyan
Write-Host "       Powered by GLM 4.7 (Z.AI)       " -ForegroundColor Cyan
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

Write-Host ""
Write-Host "Installation de Claude Code..." -ForegroundColor Yellow

# Install claude-code
npm install -g @anthropic-ai/claude-code 2>&1 | Out-Null

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERREUR] Echec de l'installation." -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Claude Code installe" -ForegroundColor Green

# Rename claude to claudy in npm folder only
$claudeCmd = Join-Path $npmPrefix "claude.cmd"
$claudyCmd = Join-Path $npmPrefix "claudy.cmd"
$claudePs1 = Join-Path $npmPrefix "claude.ps1"
$claudyPs1 = Join-Path $npmPrefix "claudy.ps1"
$claudeNoExt = Join-Path $npmPrefix "claude"
$claudyNoExt = Join-Path $npmPrefix "claudy"

if (Test-Path $claudeCmd) {
    if (Test-Path $claudyCmd) { Remove-Item $claudyCmd -Force }
    Move-Item $claudeCmd $claudyCmd -Force
}
if (Test-Path $claudePs1) {
    if (Test-Path $claudyPs1) { Remove-Item $claudyPs1 -Force }
    Move-Item $claudePs1 $claudyPs1 -Force
}
if (Test-Path $claudeNoExt) {
    if (Test-Path $claudyNoExt) { Remove-Item $claudyNoExt -Force }
    Move-Item $claudeNoExt $claudyNoExt -Force
}
Write-Host "[OK] Commande 'claudy' creee" -ForegroundColor Green

# Create .claude directory
$claudeDir = Join-Path $env:USERPROFILE ".claude"
if (-not (Test-Path $claudeDir)) {
    New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null
}

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

$settingsPath = Join-Path $claudeDir "settings.json"

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
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "glm-4.7"
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
Write-Host "[OK] 3 serveurs MCP configures :" -ForegroundColor Green
Write-Host "     - zai-vision (analyse images/videos, OCR)" -ForegroundColor Gray
Write-Host "     - web-search-prime (recherche web)" -ForegroundColor Gray
Write-Host "     - web-reader (lecture de pages web)" -ForegroundColor Gray

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "      INSTALLATION TERMINEE !          " -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Pour utiliser Claudy, tapez simplement :" -ForegroundColor White
Write-Host ""
Write-Host "    claudy" -ForegroundColor Cyan
Write-Host ""
if (-not $keyConfigured) {
    Write-Host "N'oubliez pas d'ajouter votre cle API Z.AI dans :" -ForegroundColor Yellow
    Write-Host "    $settingsPath" -ForegroundColor Cyan
    Write-Host ""
}
Write-Host "Fonctionnalites incluses :" -ForegroundColor White
Write-Host "  - GLM 4.7 (pas besoin de compte Anthropic)" -ForegroundColor Green
Write-Host "  - Vision IA (images, videos, OCR)" -ForegroundColor Green
Write-Host "  - Recherche web" -ForegroundColor Green
Write-Host "  - Lecture de pages web" -ForegroundColor Green
Write-Host "  - Mode sans permissions (pas de confirmations)" -ForegroundColor Green
Write-Host ""
