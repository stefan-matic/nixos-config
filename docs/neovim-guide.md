# Neovim Guide for Beginners

Your config: `user/app/neovim/default.nix`
Theme: Dracula (matches Ghostty + tmux)
Leader key: **Space**

> **Tip**: Press **Space** and wait — which-key will show you all available commands.

---

## 1. The Absolute Basics

### Modes (the #1 thing to understand)

Vim is a **modal editor**. You're always in one of these modes:

| Mode | How to enter | What it does |
|------|-------------|--------------|
| **Normal** | `Esc` | Navigate, run commands (you start here) |
| **Insert** | `i`, `a`, `o` | Type text like a normal editor |
| **Visual** | `v`, `V`, `Ctrl+v` | Select text |
| **Command** | `:` | Run commands (bottom of screen) |

**The golden rule**: Press `Esc` to go back to Normal mode. When in doubt, press `Esc`.

### Moving around (Normal mode)

| Key | Movement |
|-----|----------|
| `h` `j` `k` `l` | Left, Down, Up, Right (arrow keys also work) |
| `w` / `b` | Jump forward/backward by word |
| `e` | Jump to end of word |
| `0` / `$` | Jump to start/end of line |
| `gg` / `G` | Jump to top/bottom of file |
| `Ctrl+d` / `Ctrl+u` | Scroll half page down/up (stays centered) |
| `{` / `}` | Jump to previous/next blank line (paragraph) |
| `5j` / `12k` | Jump 5 lines down / 12 lines up (use the relative numbers!) |

**The relative line numbers** on the left tell you how far away each line is. To jump to a line that shows `7`, type `7j` (down) or `7k` (up).

### Entering Insert mode

| Key | Where cursor goes |
|-----|------------------|
| `i` | Before cursor |
| `a` | After cursor |
| `I` | Beginning of line |
| `A` | End of line |
| `o` | New line below |
| `O` | New line above |

### Basic editing (Normal mode)

| Key | Action |
|-----|--------|
| `x` | Delete character under cursor |
| `dd` | Delete (cut) entire line |
| `yy` | Yank (copy) entire line |
| `p` / `P` | Paste after/before cursor |
| `u` | Undo |
| `Ctrl+r` | Redo |
| `.` | Repeat last action (super powerful!) |

### The "verb + noun" pattern

Vim commands follow a pattern: **action** + **motion/object**

| Command | Meaning |
|---------|---------|
| `dw` | **d**elete **w**ord |
| `d$` | **d**elete to **$** (end of line) |
| `diw` | **d**elete **i**nner **w**ord |
| `ci"` | **c**hange **i**nside **"**quotes |
| `yap` | **y**ank (copy) **a**round **p**aragraph |
| `di(` | **d**elete **i**nside **(** parentheses |
| `va{` | **v**isual select **a**round **{** braces |

Common verbs: `d` (delete), `c` (change/replace), `y` (yank/copy), `v` (visual select)
Common objects: `w` (word), `"` `'` `` ` `` (quotes), `(` `)` `{` `}` `[` `]` (brackets), `p` (paragraph)

### Visual mode (selecting text)

| Key | Selection type |
|-----|---------------|
| `v` | Character-wise selection |
| `V` | Line-wise selection |
| `Ctrl+v` | Block/column selection |

Once selected, use `d` to delete, `y` to yank, `c` to change, `>` / `<` to indent/outdent.

### Search

| Key | Action |
|-----|--------|
| `/pattern` | Search forward |
| `?pattern` | Search backward |
| `n` / `N` | Next/previous match (stays centered) |
| `Esc` | Clear search highlighting |
| `*` | Search for word under cursor |

---

## 2. Your Custom Keybindings

All of these work in **Normal mode**. `Space` = Leader key.

### Quick actions

| Key | Action |
|-----|--------|
| `Space w` | Save file |
| `Space q` | Quit |
| `Space Q` | Quit all |
| `Space e` | Toggle file explorer (Neo-tree sidebar) |

### Find (Space f ...)

| Key | Action |
|-----|--------|
| `Space f f` | Find files by name (fuzzy search) |
| `Space f g` | Grep/search text across all project files |
| `Space f b` | Find open buffers (switch between files) |
| `Space f r` | Recent files |
| `Space f h` | Search help documentation |
| `Space f d` | Find diagnostics (errors/warnings) |

Inside Telescope (the fuzzy finder popup):
- Type to filter results
- `Ctrl+j` / `Ctrl+k` to move up/down in the list
- `Enter` to open the selected file
- `Esc` to close

### Buffers (open files) (Space b ...)

Buffers are open files. They show as tabs at the top of the screen.

| Key | Action |
|-----|--------|
| `Shift+h` | Previous buffer tab |
| `Shift+l` | Next buffer tab |
| `Space b d` | Close current buffer |
| `Space b p` | Pick a buffer (shows letter labels) |

### LSP / Code Intelligence (Space l ...)

These only work when an LSP server is attached (you'll see a language indicator in the statusbar).

| Key | Action |
|-----|--------|
| `gd` | **Go to definition** (jump to where something is defined) |
| `gr` | **Go to references** (find all usages) |
| `gI` | Go to implementation |
| `gy` | Go to type definition |
| `K` | **Hover docs** (show documentation popup) |
| `Ctrl+s` | Signature help (function parameters) |
| `Space l a` | Code action (quick fixes, refactors) |
| `Space l r` | Rename symbol (across all files) |
| `Space l f` | Format buffer |
| `Space l s` | Document symbols (outline of current file) |
| `Space l S` | Workspace symbols |

### Git (Space g ...)

| Key | Action |
|-----|--------|
| `Space g g` | Git status (fugitive - full git UI) |
| `Space g p` | Preview hunk (see what changed) |
| `Space g b` | Blame line (who wrote this?) |
| `Space g r` | Reset hunk (undo changes) |
| `Space g d` | Diff this file |
| `]h` / `[h` | Jump to next/previous git change |

Git signs show in the left gutter: `│` = added/changed, `_` = deleted.

### Trouble / Diagnostics (Space x ...)

| Key | Action |
|-----|--------|
| `Space x x` | Toggle diagnostics panel |
| `Space x d` | Buffer diagnostics only |
| `Space x t` | Show all TODOs in project |

### Other useful keys

| Key | Action |
|-----|--------|
| `s` | **Flash jump** - press `s`, type a couple chars, then the label to jump there |
| `gcc` | Toggle comment on current line |
| `gc` (visual) | Toggle comment on selection |
| `V` then `J`/`K` | Move selected lines up/down |
| `<` / `>` (visual) | Indent/outdent (keeps selection) |

---

## 3. Installed Features

### Autocomplete

Completions appear automatically as you type. Use:
- `Tab` / `Shift+Tab` to cycle through suggestions
- `Ctrl+n` / `Ctrl+p` to move next/previous
- `Enter` to accept
- `Ctrl+Space` to trigger manually
- `Ctrl+d` / `Ctrl+f` to scroll docs in the popup

Sources (in priority order): LSP suggestions, snippets, file paths, words from buffer.

### Format on Save

Files are automatically formatted when you save (`:w` or `Space w`). Formatters:

| Language | Formatter |
|----------|-----------|
| Nix | nixfmt |
| Lua | stylua |
| Python | black |
| JS/TS/JSON/YAML/HTML/CSS/MD | prettierd |
| Shell/Bash | shfmt |

### Language Servers (LSP)

These provide autocomplete, diagnostics, go-to-definition, etc:

| Language | Server |
|----------|--------|
| Nix | nil |
| Lua | lua-language-server |
| Python | pyright |
| Go | gopls |
| TypeScript/JS | typescript-language-server |
| Bash | bash-language-server |
| YAML | yaml-language-server |
| JSON/HTML/CSS | vscode-langservers-extracted |
| Terraform | terraform-ls |

### Editing helpers

- **Autopairs**: Type `(` and `)` appears automatically. Same for `"`, `'`, `{`, `[`.
- **Surround**: `cs"'` changes surrounding `"` to `'`. `ds"` deletes surrounding `"`. `ysiw"` adds `"` around a word.
- **Comment**: `gcc` toggles a comment. In visual mode, select lines then `gc`.
- **TODO highlighting**: `TODO`, `FIXME`, `HACK`, `NOTE` are highlighted in comments.

### Tmux integration

`Ctrl+h/j/k/l` moves between Neovim splits AND tmux panes seamlessly. No need to think about whether you're in vim or tmux.

### Neo-tree (file explorer)

Press `Space e` to toggle. Inside Neo-tree:
- `Enter` to open file/expand folder
- `a` to create new file
- `d` to delete
- `r` to rename
- `c` / `m` to copy / move
- `H` to toggle hidden files
- `q` to close

---

## 4. Common Workflows

### Open a file and start editing
```
nvim path/to/file.nix     # open specific file
nvim .                     # open current directory (use Space ff to find files)
```

### "I opened a file and want to find another one"
1. `Space f f` - fuzzy find by filename
2. Type part of the name, press `Enter`
3. Switch back: `Space f b` to see all open buffers, or `Shift+h`/`Shift+l`

### "I want to find some text across the whole project"
1. `Space f g` - live grep
2. Type the text you're searching for
3. Results update live, press `Enter` to jump to match

### "I want to rename a variable everywhere"
1. Put cursor on the variable
2. `Space l r` - rename
3. Type the new name, press `Enter`

### "I want to see what a function does"
1. Put cursor on the function name
2. `K` - shows documentation hover
3. `gd` - jumps to the definition

### "I messed up and want to go back"
- `u` to undo (keep pressing for more)
- `Ctrl+r` to redo
- Undo history persists even after closing the file!

### "I want to comment out several lines"
1. `V` to enter visual line mode
2. `j`/`k` to select lines
3. `gc` to toggle comments

### "I want to do a git commit"
1. `Space g g` - opens fugitive (git status view)
2. Move cursor to a file, press `s` to stage it
3. Press `cc` to commit, type message, then `:wq` to save & close

### "I want to quit"
- `Space q` - quit current window
- `Space Q` - quit everything
- `:wq` - save and quit (classic vim)
- `:q!` - quit without saving (discard changes)

---

## 5. Tips for Your First Few Days

1. **Use the mouse** - it works! Click to position cursor, scroll, click buffer tabs. No shame.

2. **Press Space and wait** - which-key shows you everything. You don't need to memorize all keys.

3. **Start with these 10 keys**: `i` (insert), `Esc` (back to normal), `Space w` (save), `Space q` (quit), `Space ff` (find file), `Space fg` (search text), `Space e` (file tree), `u` (undo), `dd` (delete line), `/` (search).

4. **The relative line numbers are your friend** - see a line 7 below? Type `7j` to jump there.

5. **Nano is still your default editor** - `$EDITOR` is still nano. Git commits, crontab, etc. all use nano. When you're comfortable, change `defaultEditor = true` in the neovim config.

6. **If you get stuck in a weird state** - press `Esc` a few times, then `u` to undo.

7. **`:` commands you'll use**:
   - `:w` save
   - `:q` quit
   - `:wq` save & quit
   - `:q!` quit without saving
   - `:%s/old/new/g` find & replace in whole file
   - `:set wrap` toggle line wrapping

8. **Run `:Tutor`** - Neovim has a built-in interactive tutorial. It takes about 30 minutes.
