# DankMaterialShell (DMS) Configuration

This directory contains the NixOS/home-manager configuration for DankMaterialShell on ZVIJER.

## Structure

```
user/wm/dms/
├── dms.nix       # Main DMS configuration file
├── PLUGINS.md    # Plugin installation guide
└── README.md     # This file
```

## Configuration Overview

DMS is configured via home-manager with all features enabled:

- ✅ System Monitoring (dgop)
- ✅ Clipboard History Manager
- ✅ VPN Management Widget
- ✅ Brightness Control
- ✅ Color Picker
- ✅ Dynamic Theming (wallpaper-based via matugen)
- ✅ Audio Visualizer (cava)
- ✅ Calendar Integration (khal)
- ✅ System Sound Support
- ✅ Systemd service integration

## Niri Compositor

DMS is optimized for use with the Niri wayland compositor. The DMS home-manager module automatically configures Niri with:

- Proper layer rules for quickshell integration
- Keybindings for DMS controls
- Window rules for floating DMS windows
- Environment variables for Wayland/Qt support

### Key Bindings

- `Mod+Space` - Toggle spotlight (app launcher)
- `Mod+M` - Process list (system monitor)
- `Mod+Comma` - Settings
- `Mod+Alt+L` - Lock screen

## System Configuration

### NixOS (system-level)
- **Location**: `hosts/_common/client.nix`
- **Package**: `niri` compositor is installed system-wide

### Home Manager (user-level)
- **Location**: `home/stefanmatic.nix` imports `user/wm/dms/dms.nix`
- **Module**: DMS flake module from `github:AvengeMedia/DankMaterialShell/stable`

## Usage

### Switching to Niri

1. Log out of your current session
2. At the login screen (SDDM), select "Niri" session
3. DMS will start automatically via systemd

### Using with Plasma (current default)

DMS can also run on KDE Plasma Wayland session, though Niri is the recommended compositor for best integration.

To test DMS without switching sessions:
```bash
systemctl --user start dms
```

## Rebuilding

After making changes to `dms.nix`:

```bash
home-manager switch --flake ~/.dotfiles#stefanmatic
```

For system changes (like updating Niri):
```bash
sudo nixos-rebuild switch --flake ~/.dotfiles#ZVIJER
```

## Customization

### Modifying DMS Configuration

Edit `user/wm/dms/dms.nix` to:
- Enable/disable features
- Adjust systemd behavior
- Add custom packages

### Adding Plugins

See `PLUGINS.md` for detailed plugin installation instructions.

### Niri Configuration

The DMS module automatically handles Niri integration. Manual Niri configuration can be added via:

```nix
wayland.windowManager.niri.settings = {
  # Your custom Niri settings
};
```

## Troubleshooting

### DMS not starting
```bash
systemctl --user status dms
journalctl --user -u dms
```

### Keybindings not working
Ensure you're running in a Niri session. Check compositor:
```bash
echo $XDG_CURRENT_DESKTOP
```

### Missing dependencies
DMS module automatically installs dependencies based on enabled features. If something is missing, check the feature flags in `dms.nix`.

## References

- [DMS Official Docs](https://danklinux.com/docs/dankmaterialshell)
- [DMS GitHub](https://github.com/AvengeMedia/DankMaterialShell)
- [Niri Compositor](https://github.com/YaLTeR/niri)
