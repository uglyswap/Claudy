/**
 * Patch Claude Code to create cli-claudy.js with CLAUDY branding
 * IMPORTANT: Does NOT modify cli.js - creates a separate cli-claudy.js file
 * This allows 'claude' command to remain unaffected while 'claudy' uses patched version
 * 
 * Usage:
 *   node patch-claudy-logo.js                    # Uses npm global path (legacy)
 *   node patch-claudy-logo.js ~/.claudy/lib      # Uses custom path (isolated install)
 * 
 * Features:
 * - CLAUDY ASCII logo with gradient colors
 * - AKHITHINK detection for rainbow animation
 * - All "Claude Code" text replaced with "Claudy"
 * - All config paths changed from ~/.claude/ to ~/.claudy/
 * - /cle-api command works via hook (see settings.json)
 */

const fs = require('fs');
const path = require('path');
const os = require('os');

// Check if custom path is provided as argument
const customLibPath = process.argv[2];

let cliPath = null;

if (customLibPath) {
    // ═══════════════════════════════════════════════════════════════════════════
    // ISOLATED INSTALLATION MODE: Use custom path (~/.claudy/lib/)
    // ═══════════════════════════════════════════════════════════════════════════
    
    // Expand ~ to home directory if needed
    let libPath = customLibPath;
    if (libPath.startsWith('~')) {
        libPath = path.join(os.homedir(), libPath.slice(1));
    }
    
    const customCliPath = path.join(libPath, 'node_modules', '@anthropic-ai', 'claude-code', 'cli.js');
    
    if (fs.existsSync(customCliPath)) {
        cliPath = customCliPath;
        console.log('[PATCH] Using isolated installation path:', libPath);
    } else {
        console.log('[WARN] cli.js not found at custom path:', customCliPath);
        process.exit(0);
    }
} else {
    // ═══════════════════════════════════════════════════════════════════════════
    // LEGACY MODE: Search in npm global paths
    // ═══════════════════════════════════════════════════════════════════════════
    
    // Get npm global path
    const npmPrefix = process.env.npm_config_prefix ||
        (process.platform === 'win32'
            ? path.join(process.env.APPDATA, 'npm')
            : '/usr/local');

    // Try multiple possible locations for cli.js
    const possiblePaths = [
        path.join(npmPrefix, 'node_modules', '@anthropic-ai', 'claude-code', 'cli.js'),
        path.join(npmPrefix, 'lib', 'node_modules', '@anthropic-ai', 'claude-code', 'cli.js')
    ];

    for (const p of possiblePaths) {
        if (fs.existsSync(p)) {
            cliPath = p;
            break;
        }
    }

    if (!cliPath) {
        console.log('[WARN] cli.js not found at expected locations');
        possiblePaths.forEach(p => console.log('  Tried:', p));
        process.exit(0);
    }
    
    console.log('[PATCH] Using npm global installation');
}

// Define path for the patched copy
const cliDir = path.dirname(cliPath);
const claudyCliPath = path.join(cliDir, 'cli-claudy.js');

console.log('[PATCH] Creating patched copy:', claudyCliPath);
console.log('[PATCH] Original cli.js remains untouched:', cliPath);

// Read original content
let content = fs.readFileSync(cliPath, 'utf8');
let patchCount = 0;

// ═══════════════════════════════════════════════════════════════════════════
// PATCH 1: Replace "Claude Code v" with "Claudy v"
// ═══════════════════════════════════════════════════════════════════════════
if (content.includes('Claude Code v')) {
    content = content.split('Claude Code v').join('Claudy v');
    patchCount++;
    console.log('  [OK] Replaced "Claude Code v" → "Claudy v"');
}

// ═══════════════════════════════════════════════════════════════════════════
// PATCH 2: Replace "Claude Code" in quotes with "Claudy"
// ═══════════════════════════════════════════════════════════════════════════
if (content.includes('"Claude Code"')) {
    content = content.split('"Claude Code"').join('"Claudy"');
    patchCount++;
    console.log('  [OK] Replaced "Claude Code" → "Claudy"');
}

// ═══════════════════════════════════════════════════════════════════════════
// PATCH 3: Replace the logo with CLAUDY ASCII art
// ═══════════════════════════════════════════════════════════════════════════

// CLAUDY ASCII Logo lines with gradient colors (Yellow -> Orange -> Rose -> Magenta)
const logoLines = [
    { text: ' ██████╗██╗      █████╗ ██╗   ██╗██████╗ ██╗   ██╗', color: '#ffff00' },
    { text: '██╔════╝██║     ██╔══██╗██║   ██║██╔══██╗╚██╗ ██╔╝', color: '#ffaf00' },
    { text: '██║     ██║     ███████║██║   ██║██║  ██║ ╚████╔╝ ', color: '#ff8700' },
    { text: '██║     ██║     ██╔══██║██║   ██║██║  ██║  ╚██╔╝  ', color: '#ff5faf' },
    { text: '╚██████╗███████╗██║  ██║╚██████╔╝██████╔╝   ██║   ', color: '#ff5fd7' },
    { text: ' ╚═════╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝    ╚═╝   ', color: '#ff87ff' }
];

const signatureLine = '              ▓▒░ CLAUDY CLI ░▒▓';
const tagline = '             ⚡ Agentic Coding ⚡';

// Original logo structure pattern - version u2
const oldLogoPattern1 = `u2.createElement(C,null,u2.createElement(C,{color:"text"}," *"),u2.createElement(C,{color:"ice_blue"}," ▐"),u2.createElement(C,{color:"ice_blue",backgroundColor:"clawd_background"},"▛███▜"),u2.createElement(C,{color:"ice_blue"},"▌"),u2.createElement(C,{color:"text"}," *")),u2.createElement(C,null,u2.createElement(C,{color:"text"},"*"),u2.createElement(C,{color:"ice_blue"}," ▝▜"),u2.createElement(C,{color:"ice_blue",backgroundColor:"clawd_background"},"█████"),u2.createElement(C,{color:"ice_blue"},"▛▘"),u2.createElement(C,{color:"text"}," *")),u2.createElement(C,null,u2.createElement(C,{color:"text"}," * "),u2.createElement(C,{color:"ice_blue"}," ▘▘ ▝▝","  "),u2.createElement(C,{color:"text"},"*"))`;

const newLogoStructure1 = [
    ...logoLines.map(line => `u2.createElement(C,{color:"${line.color}"},"${line.text}")`),
    `u2.createElement(C,{color:"#00ffff"},"${signatureLine}")`,
    `u2.createElement(C,{color:"#ffff00"},"${tagline}")`
].join(',');

if (content.includes(oldLogoPattern1)) {
    content = content.replace(oldLogoPattern1, newLogoStructure1);
    patchCount++;
    console.log('  [OK] Replaced logo pattern 1 (u2.createElement) with Claudy gradient');
}

// Original logo structure pattern - version $B
const oldLogoPattern2 = `$B.createElement(C,null,$B.createElement(C,{color:"text"}," *"),$B.createElement(C,{color:"ice_blue"}," ▐"),$B.createElement(C,{color:"ice_blue",backgroundColor:"clawd_background"},"▛███▜"),$B.createElement(C,{color:"ice_blue"},"▌"),$B.createElement(C,{color:"text"}," *")),$B.createElement(C,null,$B.createElement(C,{color:"text"},"*"),$B.createElement(C,{color:"ice_blue"}," ▝▜"),$B.createElement(C,{color:"ice_blue",backgroundColor:"clawd_background"},"█████"),$B.createElement(C,{color:"ice_blue"},"▛▘"),$B.createElement(C,{color:"text"}," *")),$B.createElement(C,null,$B.createElement(C,{color:"text"}," * "),$B.createElement(C,{color:"ice_blue"}," ▘▘ ▝▝","  "),$B.createElement(C,{color:"text"},"*"))`;

const newLogoStructure2 = [
    ...logoLines.map(line => `$B.createElement(C,{color:"${line.color}"},"${line.text}")`),
    `$B.createElement(C,{color:"#00ffff"},"${signatureLine}")`,
    `$B.createElement(C,{color:"#ffff00"},"${tagline}")`
].join(',');

if (content.includes(oldLogoPattern2)) {
    content = content.replace(oldLogoPattern2, newLogoStructure2);
    patchCount++;
    console.log('  [OK] Replaced logo pattern 2 ($B.createElement) with Claudy gradient');
}

// ═══════════════════════════════════════════════════════════════════════════
// PATCH 4: Add AKHITHINK detection to ultrathink function
// ═══════════════════════════════════════════════════════════════════════════

const ultrathinkPatterns = [
    {
        old: 'Q==="ultrathink"||Q==="think ultra hard"||Q==="think ultrahard"',
        new: 'Q==="ultrathink"||Q==="think ultra hard"||Q==="think ultrahard"||Q==="akhithink"'
    },
    {
        old: 'Q==="think ultra hard"||Q==="think ultrahard"||Q==="ultrathink"',
        new: 'Q==="think ultra hard"||Q==="think ultrahard"||Q==="ultrathink"||Q==="akhithink"'
    }
];

for (const pattern of ultrathinkPatterns) {
    if (content.includes(pattern.old) && !content.includes('"akhithink"')) {
        content = content.replace(pattern.old, pattern.new);
        patchCount++;
        console.log('  [OK] Added "akhithink" to ultrathink detection (rainbow animation enabled)');
        break;
    }
}

if (content.includes('"akhithink"')) {
    console.log('  [INFO] AKHITHINK string detection already present');
}

// ═══════════════════════════════════════════════════════════════════════════
// PATCH 5: Replace ultrathink REGEX patterns to also match "akhithink"
// ═══════════════════════════════════════════════════════════════════════════

const regexPattern1Old = '/\\bultrathink\\b/i';
const regexPattern1New = '/\\b(ultrathink|akhithink)\\b/i';

if (content.includes(regexPattern1Old) && !content.includes('akhithink)\\b/i')) {
    content = content.split(regexPattern1Old).join(regexPattern1New);
    patchCount++;
    console.log('  [OK] Patched regex /\\bultrathink\\b/i → includes akhithink');
}

const regexPattern2Old = '/\\bultrathink\\b/gi';
const regexPattern2New = '/\\b(ultrathink|akhithink)\\b/gi';

if (content.includes(regexPattern2Old) && !content.includes('akhithink)\\b/gi')) {
    content = content.split(regexPattern2Old).join(regexPattern2New);
    patchCount++;
    console.log('  [OK] Patched regex /\\bultrathink\\b/gi → includes akhithink');
}

if (content.includes('akhithink)\\b/')) {
    console.log('  [INFO] AKHITHINK regex patterns already present');
}

// ═══════════════════════════════════════════════════════════════════════════
// PATCH 6: Replace .claude/skills with .claudy/skills for user skills
// This ensures Claudy loads skills from ~/.claudy/skills/ instead of ~/.claude/skills/
// ═══════════════════════════════════════════════════════════════════════════

const skillsPathOld = '.claude/skills';
const skillsPathNew = '.claudy/skills';

const skillsOccurrences = (content.match(/\.claude\/skills/g) || []).length;
if (skillsOccurrences > 0) {
    content = content.split(skillsPathOld).join(skillsPathNew);
    patchCount++;
    console.log(`  [OK] Replaced ${skillsOccurrences}x ".claude/skills" → ".claudy/skills"`);
}

// ═══════════════════════════════════════════════════════════════════════════
// PATCH 7: Replace ".claude" config directory with ".claudy"
// This ensures ALL config paths use ~/.claudy/ instead of ~/.claude/
// Covers: settings, skills discovery, agents, hooks, etc.
// ═══════════════════════════════════════════════════════════════════════════

const configDirOccurrences = (content.match(/\"\.claude\"/g) || []).length;
if (configDirOccurrences > 0) {
    content = content.split('".claude"').join('".claudy"');
    patchCount++;
    console.log(`  [OK] Replaced ${configDirOccurrences}x ".claude" → ".claudy" (config paths)`);
}

// ═══════════════════════════════════════════════════════════════════════════
// NOTE: /cle-api command works via hook system (settings.json)
// The hook intercepts /cle-api and /cle BEFORE reaching the model
// This is more reliable than injecting into minified code
// ═══════════════════════════════════════════════════════════════════════════

console.log('  [INFO] /cle-api works via hook (no autocomplete, but more reliable)');

// ═══════════════════════════════════════════════════════════════════════════
// WRITE PATCHED COPY (NOT modifying original!)
// ═══════════════════════════════════════════════════════════════════════════

// Write the patched version to cli-claudy.js
fs.writeFileSync(claudyCliPath, content, 'utf8');

console.log(`[DONE] Created cli-claudy.js with ${patchCount} patches`);
console.log('[INFO] Original cli.js is UNCHANGED - "claude" command works normally');
console.log('[INFO] Claudy wrapper should use cli-claudy.js');
console.log('[INFO] All config now uses ~/.claudy/ instead of ~/.claude/');
console.log('[INFO] /cle-api works via hook - type "/cle-api NOUVELLE_CLE" to update');
