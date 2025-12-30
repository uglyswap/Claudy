#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Installs Claudy on Windows.

.EXAMPLE
    irm https://raw.githubusercontent.com/uglyswap/Claudy/main/install.ps1 | iex
#>

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "         CLAUDY INSTALLER              " -ForegroundColor Cyan
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

# Check if 'claude' command already exists (from another software)
$existingClaude = Get-Command claude -ErrorAction SilentlyContinue
if ($existingClaude) {
    $existingPath = $existingClaude.Source
    # Check if it's NOT in npm folder (meaning it's another software)
    $npmPrefix = npm config get prefix
    if ($existingPath -notlike "$npmPrefix*") {
        Write-Host ""
        Write-Host "[INFO] Une commande 'claude' existe deja sur votre systeme :" -ForegroundColor Yellow
        Write-Host "       $existingPath" -ForegroundColor Yellow
        Write-Host "       Claudy n'y touchera PAS. Votre logiciel existant reste intact." -ForegroundColor Yellow
        Write-Host ""
    }
}

# Get npm global path
$npmPrefix = npm config get prefix

Write-Host ""
Write-Host "Installation en cours..." -ForegroundColor Yellow
Write-Host ""

# Install claude-code
npm install -g @anthropic-ai/claude-code 2>&1 | Out-Null

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERREUR] Echec de l'installation." -ForegroundColor Red
    exit 1
}

# Rename claude to claudy in npm folder only
$claudeCmd = Join-Path $npmPrefix "claude.cmd"
$claudyCmd = Join-Path $npmPrefix "claudy.cmd"
$claudePs1 = Join-Path $npmPrefix "claude.ps1"
$claudyPs1 = Join-Path $npmPrefix "claudy.ps1"
$claudeNoExt = Join-Path $npmPrefix "claude"
$claudyNoExt = Join-Path $npmPrefix "claudy"

# Handle .cmd
if (Test-Path $claudeCmd) {
    if (Test-Path $claudyCmd) { Remove-Item $claudyCmd -Force }
    Move-Item $claudeCmd $claudyCmd -Force
}

# Handle .ps1
if (Test-Path $claudePs1) {
    if (Test-Path $claudyPs1) { Remove-Item $claudyPs1 -Force }
    Move-Item $claudePs1 $claudyPs1 -Force
}

# Handle no extension (for Git Bash)
if (Test-Path $claudeNoExt) {
    if (Test-Path $claudyNoExt) { Remove-Item $claudyNoExt -Force }
    Move-Item $claudeNoExt $claudyNoExt -Force
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
Write-Host "C'est tout ! Bonne utilisation." -ForegroundColor White
Write-Host ""
