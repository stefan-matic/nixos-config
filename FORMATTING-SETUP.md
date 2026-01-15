# Code Formatting Setup - Summary

This document summarizes the code formatting setup for the NixOS dotfiles project.

## What Was Configured

### ✅ VS Code Auto-Format on Save
- **Location**: `.vscode/settings.json`
- **What**: Automatically formats Nix files with nixfmt when you save
- **How**: Install recommended extensions (VS Code will prompt you)

### ✅ Project-Wide Formatting (treefmt)
- **Location**: `treefmt.toml`
- **What**: Format all files (Nix, Markdown, YAML, JSON) in one command
- **How**: Run `treefmt` to format everything

### ✅ Universal Editor Settings (EditorConfig)
- **Location**: `.editorconfig`
- **What**: Basic settings (indentation, line endings) for all editors
- **How**: Most editors support this automatically

### ✅ Development Environment (shell.nix)
- **Location**: `shell.nix` + `.envrc`
- **What**: All formatting tools in one place
- **How**: Run `nix-shell` or use direnv

### ✅ CI Integration
- **Location**: `.gitlab-ci.yml`
- **What**: Automatically check formatting in CI pipeline
- **How**: Runs on every commit (with `allow_failure: true`)

## Files Created/Modified

```
New Files:
├── .vscode/
│   ├── settings.json       # VS Code auto-format settings
│   ├── extensions.json     # Recommended extensions
│   └── README.md          # VS Code setup guide
├── treefmt.toml           # Multi-language formatter config
├── shell.nix              # Dev environment
├── .envrc                 # direnv integration
├── docs/
│   ├── code-style-guide.md              # Complete formatting guide
│   └── formatting-quick-reference.md    # Quick reference
└── FORMATTING-SETUP.md    # This file

Modified Files:
├── .editorconfig          # Added Markdown, YAML, JSON settings
├── .gitlab-ci.yml         # Changed to nixfmt (was alejandra)
├── scripts/validate-config.sh  # Changed to nixfmt
└── CLAUDE.md             # Added formatting section
```

## Quick Start

### Option 1: VS Code (Recommended)
1. Open project: `code ~/.dotfiles`
2. Install recommended extensions (when prompted)
3. Edit any `.nix` file
4. Save (`Ctrl+S`) → auto-formats!

### Option 2: Command Line
```bash
# Format everything
treefmt

# Check formatting
nixfmt --check .

# Enter dev environment (has all tools)
nix-shell
```

### Option 3: direnv (Automatic)
```bash
# One-time setup
cd ~/.dotfiles
direnv allow

# Tools are now automatically available when you cd here
nixfmt --version
treefmt --version
```

## What Changed from Before

### Before
- No consistent formatting
- Multiple formatters (alejandra in CI)
- Manual formatting only
- No editor integration

### After
- **nixfmt (RFC style)** everywhere
- Auto-format on save in VS Code
- `treefmt` for batch formatting
- CI checks formatting automatically
- Dev environment with all tools

## Usage Examples

### Daily Workflow (VS Code)
```bash
# 1. Open VS Code
code ~/.dotfiles

# 2. Edit files
# Save automatically formats!

# 3. Before committing
treefmt  # Format any files you didn't open in VS Code

# 4. Commit
git add .
git commit -m "Your changes"
```

### Daily Workflow (Command Line)
```bash
# 1. Edit files with your editor
vim file.nix

# 2. Format before committing
treefmt

# 3. Commit
git add .
git commit -m "Your changes"
```

### CI Pipeline
```bash
# Push to GitLab
git push

# CI automatically:
# 1. Checks formatting with nixfmt
# 2. Runs statix linting
# 3. Runs deadnix check
# 4. Validates flake

# If formatting fails:
# - Pipeline shows warning (doesn't block)
# - Run: treefmt
# - Commit and push fix
```

## Formatting Standards

### Nix Files
- **Formatter**: nixfmt-rfc-style
- **Standard**: [RFC 166](https://github.com/NixOS/rfcs/blob/master/rfcs/0166-nix-formatting.md)
- **Indentation**: 2 spaces
- **Line length**: ~100 chars (auto-wrapped)

### Other Files
- **Markdown**: prettier (2-space indent, no line length limit)
- **YAML**: prettier (2-space indent)
- **JSON**: prettier (2-space indent)

## Available Tools

In the dev environment (`nix-shell`):
- `nixfmt` - Format Nix files (RFC style)
- `treefmt` - Format all files
- `statix` - Lint Nix code
- `deadnix` - Find dead code
- `nil` - Nix language server
- `prettier` - Format Markdown/YAML/JSON
- `git` / `gh` - Git tools

## Documentation

**Quick Reference** (start here):
- `docs/formatting-quick-reference.md` - Common commands and shortcuts

**Detailed Guides**:
- `docs/code-style-guide.md` - Complete formatting guide
- `.vscode/README.md` - VS Code setup details
- `.gitlab/QUICK-START.md` - CI pipeline quick start

**Project Documentation**:
- `CLAUDE.md` - Main project documentation
- `docs/ci-pipeline-guide.md` - CI/CD details

## Next Steps

### For VS Code Users
1. ✅ Install recommended extensions
2. ✅ Edit and save files (auto-formats)
3. ✅ Run `treefmt` before committing
4. ✅ Push to GitLab

### For Command Line Users
1. ✅ Run `nix-shell` or setup direnv
2. ✅ Format with `treefmt` after editing
3. ✅ Check with `nixfmt --check .`
4. ✅ Push to GitLab

### Optional Enhancements
- Setup pre-commit hooks (see `docs/code-style-guide.md`)
- Configure your editor (see `.vscode/README.md` for examples)
- Schedule CI to run formatting fix commits automatically

## Troubleshooting

### "nixfmt: command not found"
```bash
# Use nix-shell
nix-shell

# Or install globally
nix profile install nixpkgs#nixfmt-rfc-style
```

### VS Code not formatting
1. Install extensions: `jnoortheen.nix-ide`
2. Reload window: `Ctrl+Shift+P` → "Reload Window"
3. Check file type: Bottom right should say "Nix"

### CI formatting check fails
```bash
# Fix locally
treefmt

# Commit
git add .
git commit -m "Apply nixfmt formatting"
git push
```

## Questions?

See the detailed guides:
- **Quick reference**: `docs/formatting-quick-reference.md`
- **Complete guide**: `docs/code-style-guide.md`
- **VS Code**: `.vscode/README.md`
- **CI/CD**: `.gitlab/QUICK-START.md`

---

**Happy formatting! 🎨**
