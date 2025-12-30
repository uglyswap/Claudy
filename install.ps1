#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Installs Claudy (Claude Code with 'claudy' command) on Windows.

.DESCRIPTION
    This script installs @anthropic-ai/claude-code globally via npm
    and renames the 'claude' command to 'claudy'.

.EXAMPLE
    irm https://raw.githubusercontent.com/uglyswap/Claudy/main/install.ps1 | iex
#>

$ErrorActionPreference = "Stop"

Write-Host "=== Claudy Installer ===" -ForegroundColor Cyan

# Check if Node.js is installed
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Error "Node.js is not installed. Please install Node.js 18+ from https://nodejs.org/"
    exit 1
}

$nodeVersion = (node --version) -replace 'v', ''
$nodeMajor = [int]($nodeVersion.Split('.')[0])
if ($nodeMajor -lt 18) {
    Write-Error "Node.js 18+ is required. Current version: $nodeVersion"
    exit 1
}
Write-Host "[OK] Node.js $nodeVersion detected" -ForegroundColor Green

# Check if npm is installed
if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Error "npm is not installed."
    exit 1
}
Write-Host "[OK] npm detected" -ForegroundColor Green

# Get npm global bin path
$npmBinPath = (npm config get prefix) + "\node_modules\.bin"
$npmRootBin = (npm config get prefix)

Write-Host "`nInstalling @anthropic-ai/claude-code..." -ForegroundColor Yellow
npm install -g @anthropic-ai/claude-code

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to install @anthropic-ai/claude-code"
    exit 1
}
Write-Host "[OK] claude-code installed" -ForegroundColor Green

# Find and rename claude to claudy
$claudePath = Join-Path $npmRootBin "claude.cmd"
$claudyPath = Join-Path $npmRootBin "claudy.cmd"
$claudePs1Path = Join-Path $npmRootBin "claude.ps1"
$claudyPs1Path = Join-Path $npmRootBin "claudy.ps1"
$claudeNoExtPath = Join-Path $npmRootBin "claude"
$claudyNoExtPath = Join-Path $npmRootBin "claudy"

Write-Host "`nRenaming 'claude' to 'claudy'..." -ForegroundColor Yellow

# Rename .cmd file
if (Test-Path $claudePath) {
    if (Test-Path $claudyPath) { Remove-Item $claudyPath -Force }
    Copy-Item $claudePath $claudyPath
    Remove-Item $claudePath -Force
    Write-Host "[OK] claude.cmd -> claudy.cmd" -ForegroundColor Green
}

# Rename .ps1 file
if (Test-Path $claudePs1Path) {
    if (Test-Path $claudyPs1Path) { Remove-Item $claudyPs1Path -Force }
    Copy-Item $claudePs1Path $claudyPs1Path
    Remove-Item $claudePs1Path -Force
    Write-Host "[OK] claude.ps1 -> claudy.ps1" -ForegroundColor Green
}

# Rename file without extension (for Git Bash, etc.)
if (Test-Path $claudeNoExtPath) {
    if (Test-Path $claudyNoExtPath) { Remove-Item $claudyNoExtPath -Force }
    Copy-Item $claudeNoExtPath $claudyNoExtPath
    Remove-Item $claudeNoExtPath -Force
    Write-Host "[OK] claude -> claudy" -ForegroundColor Green
}

Write-Host "`n=== Installation Complete! ===" -ForegroundColor Cyan
Write-Host "You can now use 'claudy' in any terminal." -ForegroundColor Green
Write-Host "`nTry it now:" -ForegroundColor Yellow
Write-Host "  claudy" -ForegroundColor White
