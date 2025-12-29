# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a NixOS flake-based configuration repository managing multiple hosts and home-manager configurations for user "stefanmatic". The setup uses flakes with multiple nixpkgs channels (stable and unstable) via overlays.

**Philosophy**: System manages infrastructure, Home Manager manages user applications (Philosophy B - full separation).

## Build Commands

### System Configuration

```bash
# Rebuild system configuration for current host
sudo nixos-rebuild switch --flake ~/.dotfiles

# Rebuild for specific host
sudo nixos-rebuild switch --flake ~/.dotfiles#ZVIJER
sudo nixos-rebuild switch --flake ~/.dotfiles#stefan-t14
sudo nixos-rebuild switch --flake ~/.dotfiles#starlabs
sudo nixos-rebuild switch --flake ~/.dotfiles#z420

# Remote rebuild for z420
nixos-rebuild switch --flake ~/.dotfiles#z420 --target-host z420 --use-remote-sudo
```

### Home Manager

```bash
# Apply home-manager configuration (legacy, defaults to ZVIJER setup)
home-manager switch --flake ~/.dotfiles

# For specific user@host (recommended for host-specific configs like Niri)
home-manager switch --flake ~/.dotfiles#stefanmatic@ZVIJER
home-manager switch --flake ~/.dotfiles#stefanmatic@t14
home-manager switch --flake ~/.dotfiles#stefanmatic@starlabs

# For specific user only (no host-specific configs)
home-manager switch --flake ~/.dotfiles#stefanmatic
home-manager switch --flake ~/.dotfiles#fallen
```

### Maintenance

```bash
# List generations
nix-env --list-generations
home-manager generations

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
- `nixpkgs` - Main channel (currently nixos-25.11)
- `nixpkgs-stable` - Stable channel (25.11)
- `nixpkgs-unstable` - Unstable packages
- `home-manager` - User environment management (release-25.11)
- `dms` - DankMaterialShell (Wayland desktop shell)

**Outputs:**
- `nixosConfigurations` - Hosts: ZVIJER, stefan-t14, starlabs, z420, liveboot, liveboot-iso
- `homeConfigurations` - Users: stefanmatic (+ host-specific), fallen
- `packages` - Custom packages from ./pkgs
- `overlays` - Package overlays (additions, modifications, stable/unstable packages)

### Directory Layout

```
.
├── flake.nix                 # Main flake configuration
├── docs/                     # Documentation
│   ├── REFACTOR-SUMMARY.md  # Philosophy B implementation details
│   ├── home-manager-guide.md # Home Manager operations guide
│   ├── devbox-guide.md      # Devbox development environments guide
│   └── nixos-vs-home-manager-guide.md # Package placement philosophy
├── hosts/                    # Host-specific configurations
│   ├── _common/
│   │   ├── default.nix      # Common config for all hosts
│   │   └── client.nix       # Desktop/client systems config
│   ├── zvijer/              # Gaming/workstation host
│   │   ├── configuration.nix
│   │   ├── packages.nix     # ZVIJER-specific system packages
│   │   └── env.nix
│   ├── t14/                 # Lenovo ThinkPad laptop
│   │   ├── configuration.nix
│   │   ├── packages.nix     # T14-specific system packages
│   │   └── env.nix
│   ├── starlabs/            # StarLabs laptop
│   │   ├── configuration.nix
│   │   ├── packages.nix     # StarLabs-specific system packages
│   │   └── env.nix
│   └── z420/                # HP Workstation server
│       ├── configuration.nix
│       └── env.nix
├── home/                     # Home-manager configurations
│   ├── _common.nix          # Common home config (imports user packages)
│   ├── stefanmatic.nix      # User-specific config (imports package categories)
│   └── services/            # User services (deej, etc.)
├── system/                   # System-level modules
│   ├── app/                 # Application configs (docker, virtualization)
│   ├── devices/             # Hardware-specific configs
│   ├── security/            # Security configs (firewall)
│   └── packages/            # System package modules (Philosophy B)
│       ├── common.nix       # Essential system tools (all hosts)
│       ├── hardware.nix     # Hardware tools & control
│       ├── monitoring.nix   # System monitoring & debugging
│       └── desktop.nix      # Desktop infrastructure (Wayland, etc.)
├── user/                     # User application configurations
│   ├── app/                 # App configs (git, terminal, browsers)
│   ├── lang/                # Language-specific setups
│   ├── shells/              # Shell configurations
│   ├── wm/                  # Window manager configurations
│   │   └── niri/            # Host-specific Niri configs
│   │       ├── ZVIJER.nix   # 57" ultrawide dual monitor setup
│   │       └── laptop.nix   # Generic laptop config (t14, starlabs)
│   └── packages/            # User package modules (Philosophy B)
│       ├── common.nix       # Apps for all hosts
│       ├── development.nix  # Dev tools, IDEs, DevOps, cloud CLIs
│       ├── communication.nix # Chat, video conferencing
│       ├── creative.nix     # Video editing, 3D modeling
│       ├── gaming.nix       # Gaming tools & compatibility
│       └── productivity.nix # Notes, VPN, utilities
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
3. Import `./packages.nix` for host-specific system packages
4. Import hardware-configuration.nix and any device-specific modules
5. Define host-specific services and options

**Three-tier hierarchy:**
1. `hosts/_common/default.nix` - Common to ALL hosts (servers + clients)
2. `hosts/_common/client.nix` - Common to ALL client/desktop hosts
3. `hosts/{hostname}/packages.nix` - Unique to specific host only

**Key settings passed to modules:**
- `userSettings`: username, name, email, theme, terminal, font, editor
- `systemSettings`: hostname, timezone, locale

### Philosophy B: System vs Home Manager

**System packages** (`system/packages/` and `hosts/{host}/packages.nix`):
- Essential system tools (git, vim, wget)
- Hardware-related tools (lm_sensors, pciutils)
- System monitoring & debugging (htop, iotop, strace)
- Desktop infrastructure (Wayland tools, file managers)
- Hardware-specific packages (Razer tools for ZVIJER)

**User packages** (`user/packages/`):
- Development tools (IDEs, cloud CLIs, DevOps tools)
- Communication apps (Slack, Discord, Zoom)
- Productivity software (LibreOffice, notes, VPN)
- Creative tools (video editing, 3D modeling)
- Gaming (Lutris, Wine, Vulkan)
- Media players, browsers, utilities

**Decision framework:**
- Multiple users need it? → System
- Requires root/system-level access? → System
- Hardware-related? → System
- Personal application? → Home Manager
- Can run without root? → Home Manager
- User wants independent management? → Home Manager

See `docs/nixos-vs-home-manager-guide.md` and `docs/REFACTOR-SUMMARY.md` for details.

### Package Organization

**System Packages** (~40 total):
- `system/packages/common.nix` - git, vim, wget, compression tools, python3
- `system/packages/hardware.nix` - sensors, pciutils, usbutils, brightnessctl, gparted
- `system/packages/monitoring.nix` - htop, iotop, iftop, strace, ltrace, lsof
- `system/packages/desktop.nix` - Wayland tools, nautilus, KDE utilities, xdotool

**User Packages** (~80+ total):
- `user/packages/common.nix` - Browsers, ghostty, fastfetch, media players, LibreOffice
- `user/packages/development.nix` - Cursor, kubectl, awscli2, terraform, claude-code
- `user/packages/communication.nix` - Slack, Discord, Element, Zoom, Remmina
- `user/packages/creative.nix` - Kdenlive, Prusa Slicer, OpenSCAD, ImageMagick
- `user/packages/gaming.nix` - Lutris, Wine, Vulkan tools
- `user/packages/productivity.nix` - Affine, ProtonVPN, custom utilities

**Host-specific packages:**
- `hosts/zvijer/packages.nix` - Razer hardware (openrazer-daemon, razergenie, input-remapper), kdialog
- `hosts/t14/packages.nix` - Empty (placeholder for T14-specific hardware)
- `hosts/starlabs/packages.nix` - Empty (placeholder for StarLabs-specific hardware)

**Common client packages** (`hosts/_common/client.nix`):
- google-chrome, cloudflare-warp, select-browser, fuzzel
- Yubikey support (yubioath-flutter, pcsclite)
- Utilities (zbar, nix-prefetch-git, os-prober)

### Overlays System

The repository uses four overlays (defined in `overlays/default.nix`):

1. **additions** - Custom packages from `./pkgs`
2. **modifications** - Package version overrides and patches
3. **stable-packages** - Access stable channel via `pkgs.stable.*`
4. **unstable-packages** - Access unstable channel via `pkgs.unstable.*`

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

**ZVIJER (Gaming/Workstation Desktop):**
- Gaming setup with Steam, Lutris, Wine (via home-manager)
- OBS Studio with plugins for streaming (system-level)
- Razer hardware support (openrazer daemon, razergenie, input-remapper)
- DankMaterialShell (DMS) with Niri compositor
- Arduino/Stream Deck udev rules
- Dual-boot with Windows 11 (GRUB configuration)
- Syncthing for file synchronization with Unraid server
- Python3 symlinks at /bin/python3 for compatibility
- 57" ultrawide + secondary monitor setup

**T14 (Lenovo ThinkPad Laptop):**
- DankMaterialShell (DMS) with Niri compositor
- Laptop-optimized Niri config (2-column default, touchpad)
- Syncthing, TeamViewer, OBS
- Full user package suite via home-manager

**StarLabs (StarLabs Laptop):**
- DankMaterialShell (DMS) with Niri compositor
- Laptop-optimized Niri config (shared with T14)
- Syncthing, TeamViewer, OBS
- Full user package suite via home-manager

**Z420 (HP Workstation Server):**
- Minimal server configuration
- Syncthing only
- No desktop environment

**Home-manager services:**
- deej-new: Volume control via serial connection (Arduino)
- KDE Connect: Phone integration
- mpris-proxy: Media controls

### Niri/DMS Configuration

Niri window manager configurations are host-specific and managed through home-manager:

**Structure:**
- System-level: DMS installed via `programs.dankMaterialShell` in host configs
- User-level: Niri config.kdl written by home-manager per host
- Location: `user/wm/niri/{HOSTNAME}.nix`

**Per-host configs:**
- `user/wm/niri/ZVIJER.nix` - 57" ultrawide optimized (3-column default, 20% widths for KeePassXC/Viber/Slack, dual monitor setup)
- `user/wm/niri/laptop.nix` - Generic laptop config (2-column default, touchpad support, single screen) - shared by t14 and starlabs

**Usage:**
```bash
# Apply ZVIJER-specific Niri config (ultrawide dual monitor)
home-manager switch --flake ~/.dotfiles#stefanmatic@ZVIJER

# Apply laptop Niri config (t14 or starlabs)
home-manager switch --flake ~/.dotfiles#stefanmatic@t14
home-manager switch --flake ~/.dotfiles#stefanmatic@starlabs
```

**Key patterns:**
- Host-specific configs imported via flake homeConfigurations
- Each host can have completely different layouts, startup apps, keybindings
- Configs write to `~/.config/niri/config.kdl`
- DMS provides desktop shell with IPC control: `dms ipc call <widget> <action>`

### Important Notes

- Experimental features enabled: `nix-command flakes`
- Trusted users: root, stefanmatic, fallen
- Automatic garbage collection: delete older than 30 days
- Automatic store optimization enabled
- System uses Plasma 6 desktop environment with SDDM (for fallback)
- Primary compositor: Niri with DankMaterialShell
- Default shell: zsh
- Unfree packages allowed globally

## Common Operations

### Adding Packages

**User Application (most common):**
```nix
# Add to appropriate file in user/packages/
# Example: user/packages/development.nix
home.packages = with pkgs; [
  new-dev-tool
];
```

**System Tool:**
```nix
# Add to appropriate file in system/packages/
# Example: system/packages/monitoring.nix
environment.systemPackages = with pkgs; [
  new-system-monitor
];
```

**Host-specific System Package:**
```nix
# Add to hosts/{hostname}/packages.nix
# Example: hosts/zvijer/packages.nix
environment.systemPackages = with pkgs; [
  razer-specific-tool
];
```

### Testing Changes

```bash
# Build without switching (test for errors)
sudo nixos-rebuild build --flake ~/.dotfiles#ZVIJER
home-manager build --flake ~/.dotfiles#stefanmatic@ZVIJER

# Switch to new configuration
sudo nixos-rebuild switch --flake ~/.dotfiles#ZVIJER
home-manager switch --flake ~/.dotfiles#stefanmatic@ZVIJER
```

### Rollback

```bash
# System rollback
sudo nixos-rebuild switch --rollback

# Home Manager rollback
home-manager generations
home-manager switch --switch-generation <number>

# Or use git
git checkout <previous-commit>
```

## Documentation

- `docs/REFACTOR-SUMMARY.md` - Complete Philosophy B implementation details
- `docs/home-manager-guide.md` - Home Manager operations and troubleshooting
- `docs/devbox-guide.md` - Per-project development environments with Devbox
- `docs/nixos-vs-home-manager-guide.md` - Package placement philosophy

## Troubleshooting

**Build fails with package conflict:**
- Check for duplicate packages in system and user configs
- Review `docs/REFACTOR-SUMMARY.md` for package inventory

**Application not found after rebuild:**
- System packages: rebuild system with `sudo nixos-rebuild switch`
- User packages: rebuild home-manager with `home-manager switch`
- Check if package is in correct location (system vs user)

**Niri config not applied:**
- Ensure using host-specific home-manager: `home-manager switch --flake ~/.dotfiles#stefanmatic@ZVIJER`
- Check `~/.config/niri/config.kdl` was generated

**DMS not starting:**
- Check systemd service: `systemctl --user status dms`
- Check logs: `journalctl --user -u dms`
- Restart: `systemctl --user restart dms`
