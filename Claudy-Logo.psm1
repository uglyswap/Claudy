# ═══════════════════════════════════════════════════════════════════════════════
#                         ██████╗██╗      █████╗ ██╗   ██╗██████╗ ██╗   ██╗
#                        ██╔════╝██║     ██╔══██╗██║   ██║██╔══██╗╚██╗ ██╔╝
#                        ██║     ██║     ███████║██║   ██║██║  ██║ ╚████╔╝ 
#                        ██║     ██║     ██╔══██║██║   ██║██║  ██║  ╚██╔╝  
#                        ╚██████╗███████╗██║  ██║╚██████╔╝██████╔╝   ██║   
#                         ╚═════╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝    ╚═╝   
#                                    ▓▒░ CLAUDY CLI ░▒▓
# ═══════════════════════════════════════════════════════════════════════════════

# ─────────────────────────────────────────────────────────────────────────────
# 🔧 CONFIGURATION GLOBALE
# ─────────────────────────────────────────────────────────────────────────────
$script:CLAUDY_LOGO_COUNT = 0
$script:CLAUDY_SHOW_EVERY_N = 3          # 🎯 Affiche 1 fois sur N appels
$script:CLAUDY_STEALTH_MODE = $false     # 🕶️ Mode stealth global

# ─────────────────────────────────────────────────────────────────────────────
# 💀 FONCTION PRINCIPALE - CLAUDY LOGO
# ─────────────────────────────────────────────────────────────────────────────
function Claudy-Logo {
    [CmdletBinding()]
    param(
        [switch]$NoLogo,                 # 🕶️ --no-logo flag
        [switch]$Force,                  # Force l'affichage même si pas le tour
        [int]$ShowEveryN = 0,            # Override du 1/N
        [switch]$NoAnimation,            # Désactive l'animation scanline
        [int]$ScanlineSpeed = 25         # Vitesse scanline (ms)
    )

    # ═══════════════════════════════════════════════════════════════════════
    # 🕶️ STEALTH MODE CHECK
    # ═══════════════════════════════════════════════════════════════════════
    if ($NoLogo -or $script:CLAUDY_STEALTH_MODE) {
        return
    }

    # ═══════════════════════════════════════════════════════════════════════
    # 🎯 AFFICHAGE 1 FOIS SUR N
    # ═══════════════════════════════════════════════════════════════════════
    $script:CLAUDY_LOGO_COUNT++
    $n = if ($ShowEveryN -gt 0) { $ShowEveryN } else { $script:CLAUDY_SHOW_EVERY_N }
    
    if (-not $Force -and ($script:CLAUDY_LOGO_COUNT % $n) -ne 1) {
        return
    }

    # ═══════════════════════════════════════════════════════════════════════
    # 🎨 ESCAPE CODES & PALETTES
    # ═══════════════════════════════════════════════════════════════════════
    $ESC   = [char]27
    $RESET = "$ESC[0m"
    $BOLD  = "$ESC[1m"
    $DIM   = "$ESC[2m"
    
    # Palette ombre (violets/magentas sombres pour le glow)
    $shadowPalette = @(53, 54, 91, 127, 163, 128, 92)
    
    # Palette DÉGRADÉ ACCENTUÉ - Plus d'étapes pour transition fluide
    # Jaune vif → Orange → Rose → Magenta
    $fluoPalette = @(
        226,    # Jaune vif
        226,    # Jaune vif (répété pour étendre le jaune)
        220,    # Jaune-orange
        214,    # Orange clair
        208,    # Orange
        202,    # Orange-rose
        204,    # Rose-orange
        206,    # Rose
        207,    # Rose-magenta
        213,    # Magenta-rose
        213     # Magenta-rose (répété pour étendre la fin)
    )
    
    # Couleur scanline (cyan/blanc électrique)
    $scanlineColor = 87

    # ═══════════════════════════════════════════════════════════════════════
    # 📝 LOGO ASCII
    # ═══════════════════════════════════════════════════════════════════════
    $lines = @(
        " ██████╗██╗      █████╗ ██╗   ██╗██████╗ ██╗   ██╗",
        "██╔════╝██║     ██╔══██╗██║   ██║██╔══██╗╚██╗ ██╔╝",
        "██║     ██║     ███████║██║   ██║██║  ██║ ╚████╔╝ ",
        "██║     ██║     ██╔══██║██║   ██║██║  ██║  ╚██╔╝  ",
        "╚██████╗███████╗██║  ██║╚██████╔╝██████╔╝   ██║   ",
        " ╚═════╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝    ╚═╝   "
    )

    # ═══════════════════════════════════════════════════════════════════════
    # 🖼️ FONCTION: AFFICHER UNE LIGNE AVEC DÉGRADÉ ET EFFETS
    # ═══════════════════════════════════════════════════════════════════════
    function Write-GlowLine {
        param(
            [string]$Line,
            [int]$ScanPos = -1,           # Position de la scanline (-1 = pas de scanline)
            [int]$ScanColor = 51,         # Couleur principale de la scanline
            [int]$TrailPos = -1,          # Position de la traînée
            [switch]$Reverse              # Direction inversée (pour effet traînée)
        )
        
        $len = $Line.Length
        $output = ""
        
        # Palette de halo étendu (du centre vers l'extérieur) - PAS DE BLANC
        $haloPalette = @($ScanColor, $ScanColor, 159, 123, 87, 81, 75)
        
        for ($i = 0; $i -lt $len; $i++) {
            $char = $Line[$i]
            $t = if ($len -gt 1) { $i / ($len - 1) } else { 0 }
            $idx = [Math]::Floor($t * ($fluoPalette.Count - 1))
            
            # Distance à la scanline principale
            $distScan = if ($ScanPos -ge 0) { [Math]::Abs($i - $ScanPos) } else { 999 }
            
            # Distance à la traînée
            $distTrail = if ($TrailPos -ge 0) { [Math]::Abs($i - $TrailPos) } else { 999 }
            
            if ($distScan -le 6) {
                # ⚡ SCANLINE AVEC HALO ÉTENDU (7 niveaux)
                $haloIdx = [Math]::Min($distScan, $haloPalette.Count - 1)
                $haloColor = $haloPalette[$haloIdx]
                $output += "$BOLD$ESC[38;5;${haloColor}m$char"
            }
            elseif ($distTrail -le 10) {
                # 🌊 TRAÎNÉE (afterglow) - dégradé vers couleur normale
                $fluoColor = $fluoPalette[$idx]
                
                # Blend cyan vers couleur normale
                if ($distTrail -le 3) {
                    $output += "$BOLD$ESC[38;5;123m$char"  # Cyan vif
                } elseif ($distTrail -le 6) {
                    $output += "$BOLD$ESC[38;5;117m$char"  # Cyan moyen
                } else {
                    $output += "$BOLD$ESC[38;5;${fluoColor}m$char"
                }
            }
            else {
                # Couleurs normales du dégradé
                $fluoColor = $fluoPalette[$idx]
                $output += "$BOLD$ESC[38;5;${fluoColor}m$char"
            }
        }
        
        Write-Host "$output$RESET"
    }

    # ═══════════════════════════════════════════════════════════════════════
    # 🚀 AFFICHAGE AVEC ANIMATION AMÉLIORÉE
    # ═══════════════════════════════════════════════════════════════════════
    Clear-Host
    
    $maxLen = ($lines | ForEach-Object { $_.Length } | Measure-Object -Maximum).Maximum
    $lineCount = $lines.Count
    
    if ($NoAnimation) {
        # ─────────────────────────────────────────────────────────────────
        # MODE STATIQUE (sans animation)
        # ─────────────────────────────────────────────────────────────────
        Write-Host ""
        foreach ($line in $lines) {
            Write-GlowLine -Line $line -ScanPos -1
        }
    } else {
        # ─────────────────────────────────────────────────────────────────
        # 🧬 MODE ANIMÉ AMÉLIORÉ - 3 PHASES
        # ─────────────────────────────────────────────────────────────────
        
        Write-Host ""
        $startY = [Console]::CursorTop
        
        # ═══════════════════════════════════════════════════════════════
        # PHASE 1: RÉVÉLATION PROGRESSIVE (ligne par ligne)
        # ═══════════════════════════════════════════════════════════════
        for ($lineIdx = 0; $lineIdx -lt $lineCount; $lineIdx++) {
            [Console]::SetCursorPosition(0, $startY)
            
            # Afficher les lignes déjà révélées
            for ($l = 0; $l -lt $lineIdx; $l++) {
                Write-GlowLine -Line $lines[$l] -ScanPos -1
            }
            
            # Ligne en cours avec effet de typing
            $currentLine = $lines[$lineIdx]
            for ($charIdx = 0; $charIdx -lt $currentLine.Length; $charIdx += 4) {
                [Console]::SetCursorPosition(0, $startY + $lineIdx)
                $partialLine = $currentLine.Substring(0, [Math]::Min($charIdx + 4, $currentLine.Length))
                $padding = " " * ($currentLine.Length - $partialLine.Length)
                Write-GlowLine -Line ($partialLine + $padding) -ScanPos $charIdx
                Start-Sleep -Milliseconds 8
            }
            
            # Afficher la ligne complète
            [Console]::SetCursorPosition(0, $startY + $lineIdx)
            Write-GlowLine -Line $currentLine -ScanPos -1
        }
        
        Start-Sleep -Milliseconds 100
        
        # ═══════════════════════════════════════════════════════════════
        # PHASE 2: WAVE SPECTACULAIRE - 3 passes optimisées
        # ═══════════════════════════════════════════════════════════════
        
        # Pass 1: CYAN WAVE avec traînée → Gauche à Droite
        $trailOffset = 10
        for ($scanX = -$trailOffset; $scanX -lt ($maxLen + $trailOffset); $scanX += 3) {
            [Console]::SetCursorPosition(0, $startY)
            foreach ($line in $lines) {
                Write-GlowLine -Line $line -ScanPos $scanX -ScanColor 51 -TrailPos ($scanX - $trailOffset)
            }
            Start-Sleep -Milliseconds $ScanlineSpeed
        }
        
        # Pass 2: MAGENTA WAVE avec traînée → Droite à Gauche
        for ($scanX = ($maxLen + $trailOffset); $scanX -ge -$trailOffset; $scanX -= 3) {
            [Console]::SetCursorPosition(0, $startY)
            foreach ($line in $lines) {
                Write-GlowLine -Line $line -ScanPos $scanX -ScanColor 201 -TrailPos ($scanX + $trailOffset)
            }
            Start-Sleep -Milliseconds $ScanlineSpeed
        }
        
        # Pass 3: DOUBLE SCANLINE CONVERGENTE (des deux côtés vers le centre)
        $center = [Math]::Floor($maxLen / 2)
        for ($offset = 0; $offset -le $center; $offset += 3) {
            [Console]::SetCursorPosition(0, $startY)
            $leftPos = $offset
            $rightPos = $maxLen - $offset
            
            foreach ($line in $lines) {
                $len = $line.Length
                $lineOutput = ""
                
                for ($i = 0; $i -lt $len; $i++) {
                    $char = $line[$i]
                    $t = if ($len -gt 1) { $i / ($len - 1) } else { 0 }
                    $idx = [Math]::Floor($t * ($fluoPalette.Count - 1))
                    
                    $distLeft = [Math]::Abs($i - $leftPos)
                    $distRight = [Math]::Abs($i - $rightPos)
                    $minDist = [Math]::Min($distLeft, $distRight)
                    
                    if ($minDist -le 2) {
                        # Centre de la scanline - jaune/cyan vif (pas de blanc)
                        if ($minDist -eq 0) {
                            $lineOutput += "$BOLD$ESC[38;5;226m$char"  # Jaune vif
                        } else {
                            $lineOutput += "$BOLD$ESC[38;5;220m$char"  # Jaune-orange
                        }
                    }
                    elseif ($minDist -le 5) {
                        # Halo orange
                        $lineOutput += "$BOLD$ESC[38;5;214m$char"
                    }
                    else {
                        $fluoColor = $fluoPalette[$idx]
                        $lineOutput += "$BOLD$ESC[38;5;${fluoColor}m$char"
                    }
                }
                Write-Host "$lineOutput$RESET"
            }
            Start-Sleep -Milliseconds ([Math]::Floor($ScanlineSpeed * 0.7))
        }
        
        # Pulse final (jaune vif, pas de blanc)
        [Console]::SetCursorPosition(0, $startY)
        foreach ($line in $lines) {
            Write-Host "$BOLD$ESC[38;5;226m$line$RESET"
        }
        Start-Sleep -Milliseconds 40
        
        # Retour aux couleurs normales
        [Console]::SetCursorPosition(0, $startY)
        foreach ($line in $lines) {
            Write-GlowLine -Line $line -ScanPos -1
        }
    }

    # ═══════════════════════════════════════════════════════════════════════
    # 💀 SIGNATURE CLAUDY CLI DÉFINITIVE - CENTRÉE
    # ═══════════════════════════════════════════════════════════════════════
    Write-Host ""
    
    # Largeur du logo = 50 caractères
    $logoWidth = 50
    
    # Ligne de séparation - MAGENTA VIF
    $sepChars = "═" * $logoWidth
    Write-Host "$BOLD$ESC[38;5;201m$sepChars$RESET"
    
    # Signature principale CENTRÉE
    # ▓▒░ = 3 chars visuels, CLAUDY CLI = 12, ░▒▓ = 3 → total 18
    # Padding = (50 - 18) / 2 = 16
    Write-Host -NoNewline ("                ")
    Write-Host -NoNewline "$BOLD$ESC[38;5;51m▓▒░"
    Write-Host -NoNewline "$BOLD$ESC[38;5;213m CLAUDY CLI "
    Write-Host "$BOLD$ESC[38;5;51m░▒▓$RESET"
    
    # Tagline CENTRÉ - JAUNE VIF
    # ⚡ prend 2 cellules visuelles chacun
    # "⚡ Agentic Coding ⚡" = 2 + 16 + 2 = 20 cellules visuelles
    # Padding = (50 - 20) / 2 = 15
    Write-Host -NoNewline ("               ")
    Write-Host "$BOLD$ESC[38;5;226m⚡ Agentic Coding ⚡$RESET"
    
    # Ligne de fermeture - MAGENTA VIF
    Write-Host "$BOLD$ESC[38;5;201m$sepChars$RESET"
    Write-Host ""
}

# ─────────────────────────────────────────────────────────────────────────────
# 🕶️ FONCTIONS UTILITAIRES
# ─────────────────────────────────────────────────────────────────────────────

# Active/désactive le mode stealth global
function Set-ClaudyStealthMode {
    param([bool]$Enabled = $true)
    $script:CLAUDY_STEALTH_MODE = $Enabled
    if ($Enabled) {
        Write-Host "$([char]27)[38;5;240m[CLAUDY] Stealth mode: ON$([char]27)[0m"
    } else {
        Write-Host "$([char]27)[38;5;213m[CLAUDY] Stealth mode: OFF$([char]27)[0m"
    }
}

# Configure la fréquence d'affichage (1 sur N)
function Set-ClaudyShowFrequency {
    param([int]$N = 3)
    $script:CLAUDY_SHOW_EVERY_N = $N
    Write-Host "$([char]27)[38;5;213m[CLAUDY] Logo frequency: 1/$N$([char]27)[0m"
}

# Reset le compteur
function Reset-ClaudyLogoCount {
    $script:CLAUDY_LOGO_COUNT = 0
    Write-Host "$([char]27)[38;5;213m[CLAUDY] Counter reset$([char]27)[0m"
}

# ─────────────────────────────────────────────────────────────────────────────
# 📖 AIDE
# ─────────────────────────────────────────────────────────────────────────────
function Show-ClaudyHelp {
    $ESC = [char]27
    Write-Host ""
    Write-Host "$ESC[1m$ESC[38;5;213m╔═══════════════════════════════════════════════════════╗$ESC[0m"
    Write-Host "$ESC[1m$ESC[38;5;213m║           💀 CLAUDY-LOGO - GUIDE D'UTILISATION        ║$ESC[0m"
    Write-Host "$ESC[1m$ESC[38;5;213m╚═══════════════════════════════════════════════════════╝$ESC[0m"
    Write-Host ""
    Write-Host "$ESC[38;5;226m⚡ COMMANDES PRINCIPALES:$ESC[0m"
    Write-Host "   Claudy-Logo              Affiche le logo (1 fois sur N)"
    Write-Host "   Claudy-Logo -Force       Force l'affichage"
    Write-Host "   Claudy-Logo -NoLogo      Mode stealth (n'affiche rien)"
    Write-Host "   Claudy-Logo -NoAnimation Désactive la scanline animée"
    Write-Host ""
    Write-Host "$ESC[38;5;214m🎯 CONFIGURATION:$ESC[0m"
    Write-Host "   Set-ClaudyShowFrequency -N 5    Affiche 1 fois sur 5"
    Write-Host "   Set-ClaudyStealthMode -Enabled  Active le mode stealth"
    Write-Host "   Reset-ClaudyLogoCount           Reset le compteur"
    Write-Host ""
    Write-Host "$ESC[38;5;213m🧬 PARAMÈTRES AVANCÉS:$ESC[0m"
    Write-Host "   -ShowEveryN [int]        Override ponctuel du 1/N"
    Write-Host "   -ScanlineSpeed [int]     Vitesse en ms (défaut: 25)"
    Write-Host ""
}

# ─────────────────────────────────────────────────────────────────────────────
# 🚀 EXPORT DES FONCTIONS
# ─────────────────────────────────────────────────────────────────────────────
Export-ModuleMember -Function @(
    'Claudy-Logo',
    'Set-ClaudyStealthMode', 
    'Set-ClaudyShowFrequency',
    'Reset-ClaudyLogoCount',
    'Show-ClaudyHelp'
) -Variable @(
    'CLAUDY_LOGO_COUNT',
    'CLAUDY_SHOW_EVERY_N',
    'CLAUDY_STEALTH_MODE'
)

# ═══════════════════════════════════════════════════════════════════════════════
#                              💀 FIN DU MODULE 💀
# ═══════════════════════════════════════════════════════════════════════════════
