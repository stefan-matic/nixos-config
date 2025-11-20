# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a NixOS flake-based configuration repository managing multiple hosts and home-manager configurations for user "stefanmatic". The setup uses flakes with multiple nixpkgs channels (stable and unstable) via overlays.

## Build Commands

### System Configuration

```bash
# Rebuild system configuration for current host
sudo nixos-rebuild switch --flake ~/.dotfiles

# Rebuild for specific host
sudo nixos-rebuild switch --flake ~/.dotfiles#zvijer
sudo nixos-rebuild switch --flake ~/.dotfiles#stefan-t14
sudo nixos-rebuild switch --flake ~/.dotfiles#z420

# Remote rebuild for z420
nixos-rebuild switch --flake ~/.dotfiles#z420 --target-host z420 --use-remote-sudo
```

### Home Manager

```bash
# Apply home-manager configuration
home-manager switch --flake ~/.dotfiles

# For specific user (from flake.nix homeConfigurations)
home-manager switch --flake ~/.dotfiles#stefanmatic
```

### Maintenance

```bash
# List generations
nix-env --list-generations

# Garbage collection
nix-collect-garbage --delete-old
sudo nix-collect-garbage -d

# Clean boot entries after garbage collection
sudo /run/current-system/bin/switch-to-configuration boot

# Update flake inputs
nix flake update
```

## Architecture

### Flake Structure

**Inputs:**
- `nixpkgs` - Main channel (currently nixos-25.05)
- `nixpkgs-stable` - Stable channel (25.05)
- `nixpkgs-unstable` - Unstable packages
- `home-manager` - User environment management
- `stylix` - Unified theming

**Outputs:**
- `nixosConfigurations` - Three hosts: stefan-t14, ZVIJER, z420
- `homeConfigurations` - User: stefanmatic
- `packages` - Custom packages from ./pkgs
- `overlays` - Package overlays (additions, modifications, stable/unstable packages)

### Directory Layout

```
.
├── flake.nix                 # Main flake configuration
├── hosts/                    # Host-specific configurations
│   ├── _common/
│   │   ├── default.nix      # Common config for all hosts
│   │   └── client.nix       # Desktop/client systems config
│   ├── zvijer/              # Gaming/workstation host
│   ├── t14/                 # Laptop host
│   └── z420/                # Workstation host
├── home/                     # Home-manager configurations
│   ├── _common.nix          # Common home config
│   ├── stefanmatic.nix      # User-specific config
│   └── services/            # User services (deej, etc.)
├── system/                   # System-level modules
│   ├── app/                 # Application configs (docker, virtualization)
│   ├── devices/             # Hardware-specific configs
│   └── security/            # Security configs (firewall)
├── user/                     # User application configurations
│   ├── app/                 # App configs (git, terminal, browsers)
│   ├── lang/                # Language-specific setups
│   └── shells/              # Shell configurations
├── pkgs/                     # Custom package definitions
│   ├── default.nix
│   ├── select-browser/
│   ├── deej-serial-control/
│   └── deej-new/
├── overlays/                 # Nixpkgs overlays
│   └── default.nix          # Defines additions, modifications, stable/unstable overlays
└── themes/                   # Theme configurations
```

### Configuration Pattern

Each host configuration follows this pattern:

1. Import `env.nix` to define `systemSettings` and `userSettings`
2. Import `_common/client.nix` for desktop systems (or just `_common/default.nix` for servers)
3. Import hardware-configuration.nix and any device-specific modules
4. Define host-specific options and packages

**Key settings passed to modules:**
- `userSettings`: username, name, email, theme, terminal, font, editor
- `systemSettings`: hostname, timezone, locale

### Overlays System

The repository uses three overlays (defined in `overlays/default.nix`):

1. **additions** - Custom packages from `./pkgs`
2. **modifications** - Package version overrides and patches
3. **unstable-packages** - Access unstable channel via `pkgs.unstable.*`
4. **stable-packages** - Access stable channel via `pkgs.stable.*`

Access unstable packages in configs with: `pkgs.unstable.<package>`

### Custom Packages

Custom packages are defined in `pkgs/default.nix` and available via the additions overlay:
- `select-browser` - Browser selection utility
- `deej-serial-control` - Arduino-based volume control script
- `deej-new` - Go-based deej implementation

To build/test custom package:
```bash
nix-build -E "with import <nixpkgs> {}; callPackage ./pkgs/<package-name> {}"
```

### Special Configurations

**ZVIJER host specifics:**
- Gaming setup with Steam, Lutris, Wine
- OBS Studio with plugins for streaming
- Razer hardware support (openrazer daemon)
- Arduino/Stream Deck udev rules
- Dual-boot with Windows 11 (GRUB configuration)
- Syncthing for file synchronization with Unraid server
- Python3 symlinks at /bin/python3 for compatibility

**Home-manager services:**
- deej-new: Volume control via serial connection (Arduino)
- KDE Connect: Phone integration
- mpris-proxy: Media controls

### Important Notes

- Experimental features enabled: `nix-command flakes`
- Trusted users: root, stefanmatic, fallen
- Automatic garbage collection: delete older than 30 days
- Automatic store optimization enabled
- System uses Plasma 6 desktop environment with SDDM
- Default shell: zsh
- Unfree packages allowed globally
