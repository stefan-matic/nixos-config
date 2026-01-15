# Code Style Guide

This document describes the code style and formatting standards for this NixOS configuration.

## Overview

This project uses **nixfmt** (RFC style) for all Nix code formatting. The formatting is enforced through:

- **VS Code**: Auto-format on save
- **treefmt**: Project-wide formatting tool
- **GitLab CI**: Automated format checking
- **EditorConfig**: Basic editor settings for all editors

## Quick Start

### Format All Files

```bash
# Format everything with treefmt
treefmt

# Format specific file
treefmt path/to/file.nix

# Check formatting without changing files
treefmt --fail-on-change
```

### Format in VS Code

1. Install recommended extensions (VS Code will prompt you)
2. Save any `.nix` file → auto-formats automatically
3. Manual format: `Shift+Alt+F` (Linux) or `Cmd+Shift+P` → "Format Document"

### Check Formatting Locally

```bash
# Run validation script (includes format check)
./scripts/validate-config.sh

# Or check directly with nixfmt
nixfmt --check .
```

## Tools

### nixfmt (RFC Style)

**Official Nix formatter** following [RFC 166](https://github.com/NixOS/rfcs/blob/master/rfcs/0166-nix-formatting.md).

**Features:**

- Consistent formatting across all Nix files
- 2-space indentation
- Automatic line breaking at 100 characters
- Standardized attribute set formatting

**Installation:**

```bash
# Already available via nix run
nix run nixpkgs#nixfmt-rfc-style -- --help

# Or install globally
nix profile install nixpkgs#nixfmt-rfc-style
```

**Usage:**

```bash
# Format a file in place
nixfmt file.nix

# Check formatting without modifying
nixfmt --check file.nix

# Format entire directory
nixfmt .
```

### treefmt

**Multi-language formatter** that runs all formatters in one command.

**Features:**

- Formats Nix, Markdown, YAML, JSON
- Fast (only formats changed files)
- Configurable via `treefmt.toml`

**Installation:**

```bash
# Run via nix
nix run nixpkgs#treefmt

# Or install in your environment
nix-shell -p treefmt
```

**Usage:**

```bash
# Format all files
treefmt

# Format specific files
treefmt file1.nix file2.md

# Check without formatting (useful for CI)
treefmt --fail-on-change

# Clear cache and reformat everything
treefmt --clear-cache
```

**Configuration:**
See `treefmt.toml` in the project root.

### EditorConfig

**Universal editor configuration** that works across all editors.

**Features:**

- Sets indentation, line endings, charset
- Works in VS Code, Vim, Emacs, IntelliJ, etc.
- No installation needed (most editors support it)

**Configuration:**
See `.editorconfig` in the project root.

## VS Code Setup

### Install Extensions

Open the project in VS Code and install recommended extensions:

1. **nix-ide** - Nix language support and formatting
2. **prettier-vscode** - Markdown, YAML, JSON formatting
3. **editorconfig** - EditorConfig support

VS Code will prompt you to install these automatically.

### Manual Installation

```bash
# Install from command line
code --install-extension jnoortheen.nix-ide
code --install-extension esbenp.prettier-vscode
code --install-extension editorconfig.editorconfig
```

### Settings

Project settings are in `.vscode/settings.json`:

```json
{
  "[nix]": {
    "editor.defaultFormatter": "jnoortheen.nix-ide",
    "editor.formatOnSave": true
  }
}
```

### Keyboard Shortcuts

- **Format Document**: `Shift+Alt+F` (Linux/Windows) or `Shift+Option+F` (Mac)
- **Format Selection**: `Ctrl+K Ctrl+F` (Linux/Windows) or `Cmd+K Cmd+F` (Mac)
- **Save**: `Ctrl+S` (Linux/Windows) or `Cmd+S` (Mac) - auto-formats on save

## Style Rules

### Nix Code

**Indentation:**

- 2 spaces (no tabs)
- Consistent across all files

**Line length:**

- Soft limit: 100 characters
- Hard limit: None (nixfmt handles wrapping)

**Attribute sets:**

```nix
# Good
{
  foo = "bar";
  baz = 123;
}

# Also good (single line for short sets)
{ foo = "bar"; }
```

**Function arguments:**

```nix
# Good (short)
{ pkgs, lib, ... }:

# Good (long)
{
  pkgs,
  lib,
  config,
  inputs,
  outputs,
  ...
}:
```

**Lists:**

```nix
# Good (short)
[ "foo" "bar" "baz" ]

# Good (long)
[
  "package1"
  "package2"
  "package3"
]
```

**Let expressions:**

```nix
let
  foo = "bar";
  baz = 123;
in
{
  inherit foo baz;
}
```

### Markdown

**Line length:**

- No hard limit
- Use word wrap in editor

**Headings:**

- Use ATX style (`#` headers)
- One space after `#`

**Lists:**

- Use `-` for unordered lists
- Use `1.` for ordered lists

**Code blocks:**

````markdown
```nix
# Nix code here
```
````

### YAML

**Indentation:**

- 2 spaces
- No tabs

**Quotes:**

- Use quotes for strings with special characters
- Unquoted for simple strings

### JSON

**Indentation:**

- 2 spaces
- No trailing commas

## Pre-commit Hooks (Optional)

You can set up git hooks to format code before committing:

### Option 1: Manual Hook

Create `.git/hooks/pre-commit`:

```bash
#!/usr/bin/env bash
# Format all staged Nix files before commit

echo "Running treefmt on staged files..."
if ! treefmt --fail-on-change; then
  echo "Formatting issues found. Running treefmt to fix..."
  treefmt
  git add -u
fi
```

Make it executable:

```bash
chmod +x .git/hooks/pre-commit
```

### Option 2: Using pre-commit Framework

Install pre-commit:

```bash
nix-shell -p pre-commit
```

Create `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: local
    hooks:
      - id: nixfmt
        name: nixfmt
        entry: nixfmt
        language: system
        files: \.nix$
      - id: treefmt
        name: treefmt
        entry: treefmt --fail-on-change
        language: system
        pass_filenames: false
```

Install hooks:

```bash
pre-commit install
```

## CI/CD Integration

The GitLab CI pipeline automatically checks formatting:

**Stage:** `lint`
**Job:** `nix-fmt-check`

```yaml
nix-fmt-check:
  script:
    - nix run nixpkgs#nixfmt-rfc-style -- --check .
  allow_failure: true
```

**Note:** Formatting failures don't block the pipeline by default (`allow_failure: true`).

### Enable Strict Formatting

To fail the pipeline on formatting issues:

1. Edit `.gitlab-ci.yml`
2. Remove `allow_failure: true` from `nix-fmt-check`
3. Commit changes

## Migrating Existing Code

If you have code formatted with a different formatter (alejandra, nixpkgs-fmt):

```bash
# 1. Backup current code
git checkout -b format-migration

# 2. Format everything with nixfmt
treefmt

# Or manually:
find . -name "*.nix" -type f -exec nixfmt {} \;

# 3. Review changes
git diff

# 4. Commit
git add .
git commit -m "Migrate to nixfmt (RFC style)"
```

**Warning:** This will reformat all Nix files. Review changes before committing.

## Troubleshooting

### VS Code not formatting on save

1. Check extension is installed: `jnoortheen.nix-ide`
2. Check settings: `.vscode/settings.json` has correct config
3. Check file association: File is recognized as Nix (bottom right corner)
4. Reload window: `Ctrl+Shift+P` → "Reload Window"

### nixfmt not found

```bash
# Install globally
nix profile install nixpkgs#nixfmt-rfc-style

# Or use via nix run
nix run nixpkgs#nixfmt-rfc-style -- --help
```

### treefmt fails

```bash
# Clear cache and try again
treefmt --clear-cache

# Check configuration
cat treefmt.toml

# Run with verbose output
treefmt --verbose
```

### Different formatting in CI vs local

Make sure you're using the same version:

```bash
# Check local version
nixfmt --version

# CI uses latest from nixpkgs
# Update your local installation if needed
nix profile upgrade nixfmt-rfc-style
```

## Best Practices

1. **Format before committing**
   - Run `treefmt` or `./scripts/validate-config.sh`
   - Let CI catch any issues

2. **Use VS Code auto-format**
   - Formats on save automatically
   - Consistent style across all files

3. **Review formatting changes**
   - Check diffs before committing
   - Understand what changed

4. **Don't mix formatting and logic changes**
   - Separate commits for formatting vs code changes
   - Makes reviews easier

5. **Keep treefmt.toml up to date**
   - Add new file types as needed
   - Exclude generated files

## Additional Resources

- [RFC 166 - Nix Formatting](https://github.com/NixOS/rfcs/blob/master/rfcs/0166-nix-formatting.md)
- [nixfmt Documentation](https://github.com/NixOS/nixfmt)
- [treefmt Documentation](https://github.com/numtide/treefmt)
- [EditorConfig](https://editorconfig.org/)
