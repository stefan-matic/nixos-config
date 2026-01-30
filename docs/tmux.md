# tmux Configuration Guide

This document covers the tmux setup integrated with Ghostty for session persistence and remote access.

## Overview

tmux is configured via home-manager in `user/app/terminal/tmux.nix`. It complements Ghostty by providing:

- **Session persistence** - Sessions survive terminal crashes, disconnects, and reboots
- **Remote access** - SSH from any device and attach to running sessions
- **Multiplexing over SSH** - Splits and windows work remotely (Ghostty splits are local-only)

## Configuration

### Plugins

| Plugin                 | Purpose                                        |
| ---------------------- | ---------------------------------------------- |
| **resurrect**          | Save/restore sessions manually                 |
| **continuum**          | Automatic save (15 min) and restore on start   |
| **vim-tmux-navigator** | Seamless navigation between vim and tmux panes |
| **dracula**            | Theme matching Ghostty                         |
| **yank**               | System clipboard integration                   |

### Key Settings

- **Prefix:** `Ctrl+a` (easier than default `Ctrl+b`)
- **Mouse:** Enabled for scrolling, pane selection, resizing
- **Copy mode:** Vi-style keybindings
- **Scrollback:** 50,000 lines
- **Base index:** 1 (windows/panes start at 1, not 0)

## Keybindings

### Prefix Commands (Ctrl+a, then...)

| Key  | Action                       |
| ---- | ---------------------------- |
| `\|` | Split window vertically      |
| `-`  | Split window horizontally    |
| `c`  | New window (in current path) |
| `s`  | Session picker (tree view)   |
| `d`  | Detach from session          |
| `r`  | Reload tmux config           |
| `[`  | Enter copy mode              |
| `]`  | Paste buffer                 |

### No-Prefix Commands

| Key                           | Action       |
| ----------------------------- | ------------ |
| `Alt+Left/Right/Up/Down`      | Switch panes |
| `Ctrl+Alt+Left/Right/Up/Down` | Resize panes |

### Copy Mode (Vi-style)

| Key | Action          |
| --- | --------------- |
| `v` | Begin selection |
| `y` | Copy selection  |
| `q` | Exit copy mode  |

## Session Management

### Basic Commands

```bash
# Start new named session
tmux new -s main

# List sessions
tmux ls

# Attach to session
tmux attach -t main
tmux a              # Attach to last session

# Detach (from inside tmux)
Ctrl+a d

# Kill session
tmux kill-session -t main
```

### Session Persistence (Continuum)

Sessions are automatically:

- **Saved** every 15 minutes
- **Restored** when tmux server starts

Manual save/restore:

- `Ctrl+a Ctrl+s` - Save
- `Ctrl+a Ctrl+r` - Restore

Session data stored in: `~/.local/share/tmux/resurrect/`

## SSH Remote Access Workflow

The primary use case: SSH from your phone (or any device) and resume exactly where you left off.

### Setup

1. Ensure SSH is configured on your machine
2. Start a tmux session on your main machine:
   ```bash
   tmux new -s main
   ```

### From Phone (or any SSH client)

```bash
# Connect to your machine
ssh user@your-machine

# Attach to existing session
tmux attach -t main

# Or auto-create if doesn't exist
tmux new -A -s main
```

### Recommended Phone Apps

- **iOS:** Termius, Blink Shell
- **Android:** Termux, JuiceSSH

### Tips

- Use `tmux new -A -s main` to attach or create - handles both cases
- Keep one "main" session for general work
- Create project-specific sessions: `tmux new -s project-name`

## Ghostty + tmux Integration

### When to Use What

| Feature             | Ghostty           | tmux          |
| ------------------- | ----------------- | ------------- |
| Local splits        | Yes (native, GPU) | Yes           |
| Session persistence | No                | Yes           |
| SSH multiplexing    | No                | Yes           |
| Crash recovery      | No                | Yes           |
| Tabs                | Yes               | Yes (windows) |

### Recommended Workflow

1. Open Ghostty locally (nice rendering, native feel)
2. Start tmux inside: `tmux new -A -s main`
3. Work normally - tmux handles persistence
4. Close Ghostty anytime - session survives
5. SSH from phone - attach to same session

### Auto-start tmux in Ghostty (Enabled)

Ghostty is configured to automatically start/attach to tmux with eye candy:

- **New session:** Creates `main` session and shows random eye candy
- **Existing session:** Attaches without eye candy (you've seen it already)

This is configured in `user/app/terminal/ghostty.nix` using:

```bash
# Pseudocode of what happens:
if tmux has-session -t main; then
    tmux attach -t main        # Just attach, no eye candy
else
    tmux new -s main           # Create session
    send-keys "eye_candy"      # Show random eye candy
fi
```

## Troubleshooting

### Session Not Restoring

1. Check continuum is running: look for "Continuum" in status bar
2. Verify resurrect data exists: `ls ~/.local/share/tmux/resurrect/`
3. Manual restore: `Ctrl+a Ctrl+r`

### Colors Look Wrong

Ensure terminal supports true color:

```bash
# Test true color support
curl -s https://raw.githubusercontent.com/JohnMorales/dotfiles/master/colors/24-bit-color.sh | bash
```

The config includes fixes for Ghostty true color support.

### Mouse Not Working

1. Verify mouse is enabled: `tmux show -g mouse` should return `on`
2. Some SSH clients need mouse forwarding enabled

### Pane Navigation Conflicts with Vim

The `vim-tmux-navigator` plugin handles this. Ensure you have the matching vim plugin if using vim/neovim.

## Configuration Location

- **Nix config:** `~/.dotfiles/user/app/terminal/tmux.nix`
- **Generated config:** `~/.config/tmux/tmux.conf`
- **Session data:** `~/.local/share/tmux/resurrect/`

## Applying Changes

After modifying `tmux.nix`:

```bash
sudo nixos-rebuild switch --flake ~/.dotfiles#ZVIJER
```

Then reload tmux config (if already running):

- `Ctrl+a r` or
- `tmux source-file ~/.config/tmux/tmux.conf`
