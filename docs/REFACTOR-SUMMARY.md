# Configuration Refactor Summary
**Philosophy B Implementation: Full System/Home-Manager Separation**

## Overview

This refactor implements a clean separation between NixOS system configuration and Home Manager user configuration, following "Philosophy B" from the nixos-vs-home-manager-guide.md.

**Key Principle**: System manages infrastructure, Home Manager manages user applications and dotfiles.

## What Changed

### 📦 New Directory Structure

```
.dotfiles/
├── system/packages/        # NEW: Organized system package modules
│   ├── common.nix         # Essential system tools
│   ├── hardware.nix       # Hardware tools & control
│   ├── monitoring.nix     # System monitoring & debugging
│   └── desktop.nix        # Desktop infrastructure (Wayland, etc.)
│
├── user/packages/          # NEW: Organized user package modules
│   ├── common.nix         # Apps for all hosts
│   ├── development.nix    # Dev tools, IDEs, DevOps, cloud CLIs
│   ├── communication.nix  # Chat, video conferencing
│   ├── creative.nix       # Video editing, 3D modeling
│   ├── gaming.nix         # Gaming tools & compatibility
│   └── productivity.nix   # Notes, VPN, utilities
│
└── hosts/zvijer/
    └── packages.nix        # NEW: ZVIJER-specific system packages
```

### 🔄 Major Migrations

#### Moved to Home Manager (from System)
**~80 packages moved** - dramatically reducing system rebuild times

**Development Tools:**
- IDEs: `code-cursor`, `dbeaver-bin`
- DevOps: `kubectl`, `kubectx`, `kubernetes-helm`, `k9s`, `kubelogin`, `eksctl`, `lens`
- Cloud: `awscli2`, `azure-cli` (+ all extensions)
- IaC: `terraform`, `terragrunt`, `opentofu`
- AI: `claude-code`, `claude-monitor`, `amazon-q-cli`
- Languages: `nodejs`, `python3` (for development), `uv`
- Environments: `devbox`, `quickemu`

**Communication:**
- `slack`, `discord`, `element-desktop`, `zoom-us`, `remmina`

**Productivity:**
- `libreoffice-qt6-fresh`, `affine`
- `protonvpn-gui`, `wgnord`
- `wayfarer`, `kiro`, `streamcontroller`

**Creative:**
- Video: `kdenlive`
- 3D: `prusa-slicer`, `openscad`
- Image: `imagemagick`, `viu`, `timg`

**Gaming:**
- `lutris`, `wineWowPackages.stable`, `winetricks`
- `vulkan-tools`, `vulkan-loader`, `vulkan-validation-layers`

**Media:**
- `vlc`, `mpv`

**Utilities:**
- `veracrypt`, `qdirstat`

**Browsers:**
- `chromium`, `firefox` (moved to home-manager)

#### Moved to System (from Home Manager)
**Hardware & monitoring tools** - ensuring system-wide access

- **Monitoring:** `htop`, `iotop`, `iftop`
- **Debugging:** `strace`, `ltrace`, `lsof`
- **Hardware Info:** `lm_sensors`, `pciutils`, `usbutils`
- **Hardware Control:** `pavucontrol`, `pamixer`, `brightnessctl`

#### Eliminated Duplications
- Removed duplicate `grim`, `slurp` (now only in system)
- Removed duplicate `wl-clipboard` (now only in system)
- Consolidated browser choices in home-manager

### 📝 Updated Files

#### System Configuration

**`hosts/_common/default.nix`:**
- Now imports `system/packages/{common,hardware,monitoring}.nix`
- Keeps only essential system tools
- Retains Firefox enablement, zsh, fonts

**`hosts/_common/client.nix`:**
- Imports `system/packages/desktop.nix`
- **Reduced from ~30 packages to ~8 essential ones**
- Keeps: google-chrome, cloudflare-warp, yubikey, zbar, nix-prefetch-git, os-prober
- Removed: All personal apps, dev tools, productivity software

**`hosts/zvijer/configuration.nix`:**
- **Reduced from ~70 packages to ~1 (ntfs3g)**
- Imports `./packages.nix` for host-specific hardware
- Keeps only system services: DMS, NordVPN, OpenRazer, Syncthing, OBS, Steam, TeamViewer
- Removed: All personal applications

**`hosts/zvijer/packages.nix`:** (NEW)
- Razer hardware: `openrazer-daemon`, `razergenie`, `input-remapper`
- Custom packages: `select-browser`, `kdialog`
- System utilities: `ghostty`, `fastfetch`

#### Home Manager Configuration

**`home/_common.nix`:**
- **Reduced from ~30 packages to 0** (all moved to package modules)
- Now imports `user/packages/common.nix`
- Focuses on dotfile imports and XDG configuration
- Cleaner, more maintainable

**`home/stefanmatic.nix`:**
- Imports all user package categories:
  - `development.nix`
  - `communication.nix`
  - `productivity.nix`
  - `creative.nix`
  - `gaming.nix`
- **Separated 40+ packages into organized modules**
- Easier to enable/disable entire categories

## Benefits

### ✨ Performance
- **Faster system rebuilds**: ~80 fewer packages in system config
- **Faster home-manager rebuilds**: No hardware tools to build
- **Parallel builds**: Can rebuild system and home-manager independently

### 🎯 Clarity
- **Clear mental model**: System = infrastructure, Home = apps
- **Easy to find packages**: Organized by category
- **Better documentation**: Each module is self-documenting

### 🔧 Maintainability
- **Modular structure**: Easy to add/remove package categories
- **No duplications**: Single source of truth for each package
- **Reusable modules**: Package categories can be shared across configs

### 👥 Multi-User Ready
- User-specific apps don't pollute system
- Each user can have different applications
- System provides common infrastructure

## How to Use

### Adding Packages

**User Application:**
```nix
# Add to appropriate file in user/packages/
# user/packages/development.nix
home.packages = with pkgs; [
  new-dev-tool
];
```

**System Tool:**
```nix
# Add to appropriate file in system/packages/
# system/packages/monitoring.nix
environment.systemPackages = with pkgs; [
  new-system-monitor
];
```

### Enabling/Disabling Package Categories

In `home/stefanmatic.nix`:
```nix
imports = [
  ../user/packages/development.nix    # Keep
  ../user/packages/communication.nix  # Keep
  # ../user/packages/gaming.nix      # Comment out to disable gaming
];
```

### Creating New Categories

1. Create new file: `user/packages/category-name.nix`
2. Define packages:
```nix
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    package1
    package2
  ];
}
```
3. Import in `home/stefanmatic.nix`

## Decision Framework

When adding new packages, ask:

### Should it go in System?
- **YES** if:
  - Multiple users need it
  - Requires root/system-level access
  - Hardware-related tool
  - System service/daemon
  - Essential for system operation

- **Examples**: htop, docker, bluetooth, printing services, hardware drivers

### Should it go in Home Manager?
- **YES** if:
  - Personal application
  - Development tool
  - User-specific preference
  - Can run without root
  - User wants to manage it independently

- **Examples**: vscode, slack, browsers, dev tools, games

### Still Uncertain?
Use the "Multiple Users Test": Would another user on this system want this exact package? If no → Home Manager.

## Package Inventory

### System Packages (Total: ~40)

**Common (system/packages/common.nix):**
- git, vim, wget, dig, openssl, inetutils
- which, tree
- zip, unzip, xz, p7zip
- python3

**Hardware (system/packages/hardware.nix):**
- lm_sensors, pciutils, usbutils
- brightnessctl, pavucontrol, pamixer
- gparted, gnome-disk-utility

**Monitoring (system/packages/monitoring.nix):**
- htop, iotop, iftop
- strace, ltrace, lsof

**Desktop (system/packages/desktop.nix):**
- grim, slurp, wl-clipboard, cliphist, xwayland-satellite
- nautilus, gvfs
- kcalc, kate, kdialog
- xdotool, kdotool, ydotool
- mesa-demos

**Client-specific (hosts/_common/client.nix):**
- google-chrome, cloudflare-warp
- yubioath-flutter, pcsclite
- zbar, nix-prefetch-git, os-prober

**ZVIJER-specific (hosts/zvijer/packages.nix):**
- select-browser, kdialog
- openrazer-daemon, razergenie, input-remapper
- ghostty, fastfetch

### User Packages (Total: ~80+)

**Common (user/packages/common.nix):**
- chromium, firefox
- zip, xz, unzip, p7zip
- ipcalc, ldns
- gnupg, veracrypt
- vlc, mpv
- libreoffice-qt6-fresh
- qdirstat
- tesseract4, screenshot-ocr script

**Development (user/packages/development.nix):**
- code-cursor, dbeaver-bin
- devbox, direnv, nix-direnv, pre-commit
- nodejs, python3, python3.pkgs.pip, uv
- kubectl, kubectx, kubernetes-helm, k9s, kubelogin, eksctl, lens
- awscli2, azure-cli (+ 8 extensions)
- terraform, terragrunt, opentofu
- claude-code, claude-monitor, amazon-q-cli
- gnumake, quickemu

**Communication (user/packages/communication.nix):**
- slack, discord, element-desktop
- zoom-us, remmina

**Creative (user/packages/creative.nix):**
- kdenlive
- prusa-slicer, openscad
- imagemagick, viu, timg

**Gaming (user/packages/gaming.nix):**
- lutris
- wineWowPackages.stable, winetricks
- vulkan-tools, vulkan-loader, vulkan-validation-layers

**Productivity (user/packages/productivity.nix):**
- affine
- protonvpn-gui, wgnord
- wayfarer, kiro
- fastfetch, streamcontroller

## Testing

### Test System Build
```bash
# Should be much faster now
sudo nixos-rebuild switch --flake ~/.dotfiles#ZVIJER
```

### Test Home Manager Build
```bash
# May take longer initially (more packages)
home-manager switch --flake ~/.dotfiles#stefanmatic@ZVIJER
```

### Verify No Regressions
```bash
# Check that applications still work
code      # Should launch code-cursor
slack     # Should launch Slack
kubectl   # Should work
```

## Rollback Plan

If something breaks:

```bash
# System rollback
sudo nixos-rebuild switch --rollback

# Home Manager rollback
home-manager generations
home-manager switch --switch-generation <number>

# Or use git
git checkout <previous-commit>
```

## Next Steps

1. **Test the configuration** thoroughly
2. **Update the guide** (`docs/nixos-vs-home-manager-guide.md`) with lessons learned
3. **Consider** applying same pattern to other hosts (t14, starlabs)
4. **Monitor** rebuild times to confirm performance improvements
5. **Adjust** package categorization as needed

## Notes

- **VSCode wrapper** in `hosts/_common/default.nix` creates a `code` command that disables GPU. This could be moved to home-manager if preferred.
- **Python3** is in system for `/bin/python3` symlink compatibility, plus in user packages for development.
- **Firefox** is enabled system-wide via `programs.firefox.enable` but can also be in home-manager for user-specific profile.
- **Steam** and **OBS** remain in system as they require system-level integration.
- **Syncthing** remains in system as it's a daemon service.

## Questions?

Refer to:
- `docs/nixos-vs-home-manager-guide.md` for philosophy and guidelines
- Individual package module files for what's included where
- Git history for detailed changes
