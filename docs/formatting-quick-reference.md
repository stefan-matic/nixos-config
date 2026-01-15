# Formatting Quick Reference

## TL;DR

```bash
# Format all files
treefmt

# Check formatting
nixfmt --check .

# VS Code: Save file (Ctrl+S) - auto-formats
```

## Common Commands

### Format Everything
```bash
treefmt                          # Format all tracked files
treefmt --clear-cache            # Clear cache and reformat
```

### Format Specific Files
```bash
nixfmt file.nix                  # Format single Nix file
treefmt file1.nix file2.md       # Format multiple files
find . -name "*.nix" | xargs nixfmt  # Format all Nix files
```

### Check Formatting
```bash
nixfmt --check .                 # Check Nix files
treefmt --fail-on-change         # Check all files
./scripts/validate-config.sh     # Full validation (includes formatting)
```

## VS Code Setup

### One-time Setup
1. Open project in VS Code
2. Install recommended extensions (will be prompted)
3. Done! Save = auto-format

### Keyboard Shortcuts
- **Save & format**: `Ctrl+S` (auto-formats on save)
- **Format document**: `Shift+Alt+F`
- **Format selection**: `Ctrl+K Ctrl+F`

### Manual Extension Install
```bash
code --install-extension jnoortheen.nix-ide
code --install-extension esbenp.prettier-vscode
```

## File-Specific Formatting

### Nix Files (.nix)
```bash
nixfmt file.nix              # Format
nixfmt --check file.nix      # Check only
```

### Markdown Files (.md)
```bash
prettier --write file.md     # Format
prettier --check file.md     # Check only
```

### YAML Files (.yml, .yaml)
```bash
prettier --write file.yml    # Format
prettier --check file.yml    # Check only
```

### JSON Files (.json)
```bash
prettier --write file.json   # Format
prettier --check file.json   # Check only
```

## Development Environment

### Using nix-shell
```bash
# Enter dev environment (includes all formatters)
nix-shell

# Now you have nixfmt, treefmt, statix, etc.
```

### Using direnv (automatic)
```bash
# One-time setup
echo "use nix" > .envrc
direnv allow

# Now tools are automatically available when you cd into the directory
```

## Formatting Rules

### Nix
- **Indentation**: 2 spaces
- **Line length**: ~100 characters (auto-wrapped)
- **Style**: RFC 166 standard

### Markdown
- **Indentation**: 2 spaces
- **Line length**: No limit (word wrap)
- **Headers**: ATX style (`#`)

### YAML
- **Indentation**: 2 spaces
- **Quotes**: Smart (as needed)

### JSON
- **Indentation**: 2 spaces
- **No trailing commas**

## CI/CD

### Check Status
```
GitLab → CI/CD → Pipelines → View latest run
Look for: nix-fmt-check job
```

### Format Check Fails?
```bash
# Fix locally
treefmt

# Commit
git add .
git commit -m "Apply nixfmt formatting"
git push
```

## Troubleshooting

### "nixfmt: command not found"
```bash
# Option 1: Use via nix run
nix run nixpkgs#nixfmt-rfc-style -- --check .

# Option 2: Install globally
nix profile install nixpkgs#nixfmt-rfc-style

# Option 3: Use dev shell
nix-shell
```

### VS Code not formatting
1. Check extension installed: `jnoortheen.nix-ide`
2. Reload window: `Ctrl+Shift+P` → "Reload Window"
3. Check file type: Should say "Nix" in bottom right

### treefmt fails
```bash
# Clear cache
treefmt --clear-cache

# Run with verbose output
treefmt --verbose
```

### Different formatting in CI
```bash
# Update to latest nixfmt
nix profile upgrade nixfmt-rfc-style

# Or use exact version from nixpkgs
nix run nixpkgs#nixfmt-rfc-style -- --version
```

## Best Practices

✅ **Do:**
- Format before committing
- Use auto-format on save (VS Code)
- Run `treefmt` before pushing
- Review formatting changes in diff

❌ **Don't:**
- Mix formatting and logic changes in one commit
- Commit unformatted code
- Ignore CI formatting failures
- Format files outside the project

## Integration with Git

### Pre-commit Hook
```bash
# Create .git/hooks/pre-commit
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/sh
treefmt --fail-on-change || {
  echo "Formatting issues found. Run: treefmt"
  exit 1
}
EOF

chmod +x .git/hooks/pre-commit
```

### Format Staged Files Only
```bash
# Get staged .nix files
git diff --cached --name-only --diff-filter=ACM | grep '\.nix$' | xargs nixfmt

# Stage formatted changes
git add -u
```

## Quick Links

- **Full guide**: [code-style-guide.md](code-style-guide.md)
- **Project docs**: [../CLAUDE.md](../CLAUDE.md)
- **CI pipeline**: [ci-pipeline-guide.md](ci-pipeline-guide.md)
