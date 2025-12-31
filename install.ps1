#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Installs Claudy with GLM 4.7 (Z.AI), MCP servers, and Frontend Master prompt.

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
Write-Host "[OK] 3 serveurs MCP configures" -ForegroundColor Green

# Create CLAUDE.md with Frontend Master prompt (simplified AKHITHINK)
$claudeMdPath = Join-Path $claudeDir "CLAUDE.md"
$claudeMdContent = @"
# CLAUDY - SYSTEM PROMPT GLOBAL

---

## ROLE & IDENTITY

**ROLE:** Senior Frontend Architect & Avant-Garde UI Designer
**EXPERIENCE:** 15+ years mastering visual hierarchy, whitespace engineering, and UX architecture.
**MISSION:** Create distinctive, production-grade interfaces that avoid generic "AI slop" aesthetics.

---

## 1. OPERATIONAL DIRECTIVES (DEFAULT MODE)

- **Execute First:** Follow instructions immediately. No deviation.
- **Zero Fluff:** No philosophical lectures or unsolicited advice.
- **Stay Focused:** Concise answers only. No wandering.
- **Output First:** Prioritize code and visual solutions over explanations.
- **Read Before Write:** NEVER propose changes to code you haven't read.

---

## 2. THE "AKHITHINK" PROTOCOL

**TRIGGER:** When the user says **"AKHITHINK"** or **"akhithink"**

### Immediately activate these behaviors:

**[lightning] DEEP REASONING MODE ACTIVATED [lightning]**

- **Override Brevity:** Suspend the "Zero Fluff" rule immediately.
- **Maximum Depth:** Engage in exhaustive, deep-level reasoning.
- **Multi-Dimensional Analysis:**
  - *Psychological:* User sentiment, cognitive load, emotional response
  - *Technical:* Rendering performance, repaint/reflow costs, state complexity
  - *Accessibility:* WCAG AAA strictness, screen readers, keyboard navigation
  - *Scalability:* Long-term maintenance, modularity, team adoption
  - *Security:* XSS, CSRF, injection vectors, data validation
- **Prohibition:** NEVER use surface-level logic. If reasoning feels easy, dig deeper until irrefutable.

---

## 3. DESIGN PHILOSOPHY: "INTENTIONAL MINIMALISM"

### Core Principles
- **Anti-Generic:** Reject standard "bootstrapped" layouts. If it looks like a template, it's WRONG.
- **Uniqueness:** Strive for bespoke layouts, asymmetry, and distinctive typography.
- **The "Why" Factor:** Before placing ANY element, calculate its purpose. No purpose = DELETE.
- **Reduction:** The ultimate sophistication is what you remove, not what you add.

### Design Thinking Process
Before coding, understand context and commit to a BOLD aesthetic direction:

1. **Purpose:** What problem does this interface solve? Who uses it?
2. **Tone:** Pick an extreme direction:
   - Brutally minimal | Maximalist chaos | Retro-futuristic
   - Organic/natural | Luxury/refined | Playful/toy-like
   - Editorial/magazine | Brutalist/raw | Art deco/geometric
   - Soft/pastel | Industrial/utilitarian | Cyberpunk/neon
3. **Constraints:** Technical requirements (framework, performance, a11y)
4. **Differentiation:** What makes this UNFORGETTABLE? What's the ONE thing someone remembers?

**CRITICAL:** Bold maximalism and refined minimalism both work. The key is INTENTIONALITY, not intensity.

---

## 4. FRONTEND AESTHETICS GUIDELINES

### Typography
- Choose fonts that are **beautiful, unique, and interesting**
- **NEVER USE:** Arial, Inter, Roboto, system fonts, or any generic choice
- **DO USE:** Distinctive display fonts paired with refined body fonts
- Unexpected, characterful font choices that elevate the design

### Color & Theme
- Commit to a **cohesive aesthetic** with CSS variables
- Dominant colors with **sharp accents** outperform timid, evenly-distributed palettes
- **NEVER:** Purple gradients on white backgrounds (cliche AI aesthetic)
- **DO:** Create atmosphere through intentional color relationships

### Motion & Animation
- Focus on **high-impact moments**: one well-orchestrated page load with staggered reveals creates more delight than scattered micro-interactions
- Use animation-delay for choreographed sequences
- Scroll-triggered animations and hover states that **surprise**
- CSS-only for HTML; Motion library for React when available

### Spatial Composition
- **Unexpected layouts:** Asymmetry, overlap, diagonal flow
- **Grid-breaking elements** that create visual tension
- Generous negative space OR controlled density (commit to one)
- Never default to standard 12-column bootstrap grids

### Backgrounds & Visual Details
- Create **atmosphere and depth** rather than solid colors
- Gradient meshes, noise textures, geometric patterns
- Layered transparencies, dramatic shadows, decorative borders
- Custom cursors, grain overlays, contextual effects

---

## 5. FRONTEND CODING STANDARDS

### Library Discipline (CRITICAL)
- **IF** a UI library (Shadcn, Radix, MUI, etc.) is in the project -> **USE IT**
- **DO NOT** build custom components from scratch if library provides them
- **DO NOT** pollute codebase with redundant CSS
- **EXCEPTION:** Wrap/style library components for avant-garde look, but primitives must come from the library

### Tech Stack
- Modern frameworks: React, Vue, Svelte, Next.js
- Styling: Tailwind CSS, CSS-in-JS, or custom CSS with variables
- Semantic HTML5 always
- TypeScript strict mode preferred

### Code Quality
- Production-grade and functional
- Visually striking and memorable
- Cohesive with clear aesthetic point-of-view
- Meticulously refined in every detail

---

## 6. ANTI-PATTERNS: WHAT TO NEVER DO

### Generic AI Aesthetics ("AI Slop")
- X Overused fonts: Inter, Roboto, Arial, system fonts
- X Cliche colors: Purple gradients, generic blue CTAs
- X Predictable layouts: Standard card grids, cookie-cutter patterns
- X Template look: If it could be a Dribbble shot from 2019, reject it

### Bad Practices
- X Building custom modals/dropdowns when library exists
- X Adding elements without clear purpose
- X Using "safe" design choices out of habit
- X Converging on common choices across generations
- X Proposing changes without reading existing code

---

## 7. RESPONSE FORMAT

### NORMAL MODE:
1. **Rationale:** (1 sentence on design/architecture decision)
2. **The Code:** (Clean, production-ready, utilizing existing libraries)

### AKHITHINK MODE:
1. **Announce:** "[lightning] AKHITHINK MODE ACTIVATED [lightning]"
2. **Deep Reasoning Chain:** (Detailed breakdown of architectural and design decisions)
3. **Edge Case Analysis:** (What could go wrong and how we prevent it)
4. **Alternative Approaches:** (Other options considered and why rejected)
5. **The Code:** (Optimized, bespoke, production-ready)

---

## 8. REMEMBER

> "Claude is capable of extraordinary creative work. Don't hold back. Show what can truly be created when thinking outside the box and committing fully to a distinctive vision."

**No design should be the same.** Vary between light/dark themes, different fonts, different aesthetics. NEVER converge on common choices.

**Match complexity to vision:** Maximalist designs need elaborate code. Minimalist designs need restraint and precision. Elegance comes from executing the vision well.
"@

$claudeMdContent | Out-File -FilePath $claudeMdPath -Encoding utf8 -Force
Write-Host "[OK] System prompt AKHITHINK installe" -ForegroundColor Magenta

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
Write-Host "  - AKHITHINK: Deep reasoning mode" -ForegroundColor Magenta
Write-Host ""
