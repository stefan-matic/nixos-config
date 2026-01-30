# Code Formatting Guide

Uses **nixfmt** (RFC style) for Nix files.

## Quick Commands

```bash
# Format all files
treefmt

# Check formatting
nixfmt --check .

# Format single file
nixfmt file.nix
```

## VS Code

Auto-formats on save with `jnoortheen.nix-ide` extension.

Manual: `Shift+Alt+F`

## Style Rules

- **Indentation**: 2 spaces
- **Line length**: ~100 chars (auto-wrapped)
- **Formatter**: nixfmt-rfc-style

## CI Integration

Pipeline checks formatting in `nix-fmt-check` job.

Fix failures:

```bash
treefmt
git add . && git commit -m "Apply formatting"
```

## Troubleshooting

```bash
# nixfmt not found
nix run nixpkgs#nixfmt-rfc-style -- --check .

# Clear treefmt cache
treefmt --clear-cache
```
