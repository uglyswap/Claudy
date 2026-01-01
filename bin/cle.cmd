@echo off
REM Claudy - Mise a jour cle API (wrapper CMD)
where pwsh >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    pwsh -NoProfile -ExecutionPolicy Bypass -File "%USERPROFILE%\.claudy\bin\cle.ps1" %*
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%USERPROFILE%\.claudy\bin\cle.ps1" %*
)
