# VS Code Configuration

This directory contains VS Code settings and extension recommendations for the NixOS dotfiles project.

## Quick Start

1. **Open project in VS Code**
   ```bash
   code ~/.dotfiles
   ```

2. **Install recommended extensions**
   - VS Code will prompt you automatically
   - Or click "Install All" when prompted

3. **Start editing**
   - Save any `.nix` file → auto-formats with nixfmt
   - All settings are already configured

## Files

### settings.json
Project-specific VS Code settings:
- Auto-format on save for Nix, Markdown, YAML, JSON
- nixfmt (RFC style) as Nix formatter
- 2-space indentation
- Trim trailing whitespace
- Insert final newline

### extensions.json
Recommended extensions:
- **nix-ide**: Nix language support, formatting, LSP
- **prettier-vscode**: Markdown, YAML, JSON formatting
- **editorconfig**: EditorConfig support
- **gitlens**: Git integration
- **markdown-all-in-one**: Markdown enhancements

## Keyboard Shortcuts

### Formatting
- **Save & auto-format**: `Ctrl+S` (Linux/Windows) or `Cmd+S` (Mac)
- **Format document**: `Shift+Alt+F` (Linux/Windows) or `Shift+Option+F` (Mac)
- **Format selection**: `Ctrl+K Ctrl+F` (Linux/Windows) or `Cmd+K Cmd+F` (Mac)

### Git
- **Open source control**: `Ctrl+Shift+G`
- **Git: Commit**: `Ctrl+Enter` (in source control panel)
- **Git: Push**: `Ctrl+Shift+P` → "Git: Push"

### Search
- **Find in files**: `Ctrl+Shift+F`
- **Find file**: `Ctrl+P`
- **Command palette**: `Ctrl+Shift+P`

## Extension Details

### nix-ide
**Features:**
- Syntax highlighting
- Auto-formatting with nixfmt
- Language server (nil) integration
- Hover documentation
- Go to definition
- Code completion

**Configuration:**
```json
{
  "nix.enableLanguageServer": true,
  "nix.serverPath": "nil",
  "nix.formatterPath": "nixfmt"
}
```

### prettier-vscode
**Features:**
- Format Markdown files
- Format YAML files
- Format JSON files
- Configurable via `.prettierrc` (optional)

## Customization

### Override Settings

Create a user settings file (won't be committed):
```bash
# Create .vscode/settings.local.json
{
  "editor.fontSize": 14,
  "workbench.colorTheme": "Your Theme"
}
```

Add to `.gitignore`:
```gitignore
.vscode/settings.local.json
```

### Add More Extensions

Edit `extensions.json`:
```json
{
  "recommendations": [
    "existing.extension",
    "your.new-extension"
  ]
}
```

## Troubleshooting

### Extensions not installing
1. Check internet connection
2. Reload window: `Ctrl+Shift+P` → "Reload Window"
3. Install manually: `Ctrl+Shift+X` → Search for extension

### Formatter not working
1. Check extension installed: Look for "nix-ide" in Extensions panel
2. Check file type: Bottom right should say "Nix"
3. Check output: `Ctrl+Shift+U` → Select "Nix IDE" from dropdown
4. Reload window: `Ctrl+Shift+P` → "Reload Window"

### Wrong formatter being used
1. Right-click in editor → "Format Document With..."
2. Select "nix-ide"
3. Check "Configure Default Formatter"

### Settings not applying
1. Check you're in the project workspace (not just a folder)
2. Close and reopen VS Code
3. Check for conflicting user settings: `Ctrl+,` → Search for setting

## Alternative Editors

If you prefer other editors, see:
- **Vim/Neovim**: Use `nil` language server + `nixfmt` command
- **Emacs**: Use `lsp-mode` with `nil` + `nixfmt`
- **IntelliJ**: Use Nix plugin
- **Sublime Text**: Use LSP package + `nil`

All editors should respect `.editorconfig` for basic settings.

## More Information

- **Formatting guide**: [../docs/code-style-guide.md](../docs/code-style-guide.md)
- **Quick reference**: [../docs/formatting-quick-reference.md](../docs/formatting-quick-reference.md)
- **Project docs**: [../CLAUDE.md](../CLAUDE.md)
