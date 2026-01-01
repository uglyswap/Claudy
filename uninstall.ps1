#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Uninstalls Claudy completely without touching Claude Code.

.DESCRIPTION
    This script removes:
    - ~/.claudy/ folder (all files and subfolders)
    - claudy.cmd wrapper from npm global directory
    - ~/.claudy/bin from user PATH
    
    It does NOT touch:
    - Claude Code CLI (claude command)
    - ~/.claude/ folder
    - Any other npm packages

.EXAMPLE
    PowerShell:
    irm https://raw.githubusercontent.com/uglyswap/Claudy/main/uninstall.ps1 | iex
    
    CMD:
    curl -fsSL https://raw.githubusercontent.com/uglyswap/Claudy/main/uninstall.ps1 -o %TEMP%\uninstall.ps1 && powershell -ExecutionPolicy Bypass -File %TEMP%\uninstall.ps1
#>

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "      CLAUDY UNINSTALLER               " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Claudy is installed
$claudyDir = Join-Path $env:USERPROFILE ".claudy"
$npmDir = Join-Path $env:APPDATA "npm"

$claudyExists = Test-Path $claudyDir
$wrapperExists = Test-Path (Join-Path $npmDir "claudy.cmd")

if (-not $claudyExists -and -not $wrapperExists) {
    Write-Host "[INFO] Claudy n'est pas installe sur ce systeme." -ForegroundColor Yellow
    Write-Host ""
    exit 0
}

Write-Host "Composants detectes:" -ForegroundColor White
if ($claudyExists) {
    $size = (Get-ChildItem $claudyDir -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
    $sizeMB = [math]::Round($size / 1MB, 2)
    Write-Host "  [X] Dossier ~/.claudy/ ($sizeMB MB)" -ForegroundColor Yellow
} else {
    Write-Host "  [ ] Dossier ~/.claudy/ (non trouve)" -ForegroundColor Gray
}

if ($wrapperExists) {
    Write-Host "  [X] Wrapper npm claudy.cmd" -ForegroundColor Yellow
} else {
    Write-Host "  [ ] Wrapper npm claudy.cmd (non trouve)" -ForegroundColor Gray
}

# Check PATH
$userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
$claudyInPath = $userPath -like "*\.claudy\bin*"
if ($claudyInPath) {
    Write-Host "  [X] ~/.claudy/bin dans PATH" -ForegroundColor Yellow
} else {
    Write-Host "  [ ] ~/.claudy/bin dans PATH (non trouve)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Claude Code (officiel) ne sera PAS touche:" -ForegroundColor Green
Write-Host "  - Commande 'claude' preservee" -ForegroundColor Gray
Write-Host "  - Dossier ~/.claude/ preserve" -ForegroundColor Gray
Write-Host ""

# Confirm uninstallation
$confirm = Read-Host "Voulez-vous desinstaller Claudy? (O/n)"
if ($confirm -eq "n" -or $confirm -eq "N") {
    Write-Host ""
    Write-Host "[ANNULE] Desinstallation annulee." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Desinstallation en cours..." -ForegroundColor Yellow
Write-Host ""

$errors = @()

# Step 1: Remove ~/.claudy/ folder
if ($claudyExists) {
    try {
        Remove-Item -Path $claudyDir -Recurse -Force -ErrorAction Stop
        Write-Host "[OK] Dossier ~/.claudy/ supprime" -ForegroundColor Green
    } catch {
        $errMsg = $_.Exception.Message
        $errors += "Impossible de supprimer ~/.claudy/ - $errMsg"
        Write-Host "[ERREUR] Impossible de supprimer ~/.claudy/" -ForegroundColor Red
        Write-Host "         Fermez Claudy s'il est en cours d'execution" -ForegroundColor Gray
    }
}

# Step 2: Remove npm wrappers (claudy, claudy.cmd, claudy.ps1)
$wrappers = @("claudy", "claudy.cmd", "claudy.ps1")
foreach ($wrapper in $wrappers) {
    $wrapperPath = Join-Path $npmDir $wrapper
    if (Test-Path $wrapperPath) {
        try {
            Remove-Item -Path $wrapperPath -Force -ErrorAction Stop
            Write-Host "[OK] Wrapper $wrapper supprime" -ForegroundColor Green
        } catch {
            $errMsg = $_.Exception.Message
            $errors += "Impossible de supprimer $wrapper - $errMsg"
            Write-Host "[ERREUR] Impossible de supprimer $wrapper" -ForegroundColor Red
        }
    }
}

# Step 3: Remove ~/.claudy/bin from PATH
if ($claudyInPath) {
    try {
        $claudyBinDir = Join-Path $env:USERPROFILE ".claudy\bin"
        $newPath = ($userPath -split ";" | Where-Object { $_ -ne $claudyBinDir -and $_ -ne "" }) -join ";"
        [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
        Write-Host "[OK] ~/.claudy/bin retire du PATH" -ForegroundColor Green
    } catch {
        $errMsg = $_.Exception.Message
        $errors += "Impossible de modifier le PATH - $errMsg"
        Write-Host "[ERREUR] Impossible de modifier le PATH" -ForegroundColor Red
    }
}

# Final status
Write-Host ""
if ($errors.Count -eq 0) {
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "   CLAUDY DESINSTALLE AVEC SUCCES !    " -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "La commande 'claudy' n'est plus disponible." -ForegroundColor White
    Write-Host ""
    Write-Host "Pour reinstaller Claudy:" -ForegroundColor Gray
    Write-Host "  irm https://raw.githubusercontent.com/uglyswap/Claudy/main/install.ps1 | iex" -ForegroundColor Cyan
} else {
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "  DESINSTALLATION PARTIELLE            " -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Certains composants n'ont pas pu etre supprimes:" -ForegroundColor Red
    foreach ($err in $errors) {
        Write-Host "  - $err" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "Essayez de:" -ForegroundColor Yellow
    Write-Host "  1. Fermer toutes les instances de Claudy" -ForegroundColor Gray
    Write-Host "  2. Relancer ce script en tant qu'administrateur" -ForegroundColor Gray
}

Write-Host ""
