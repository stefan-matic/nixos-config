# DankMaterialShell (DMS) Configuration

This directory contains the NixOS/home-manager configuration for DankMaterialShell on ZVIJER.

## Structure

```
user/wm/dms/
├── dms.nix                  # Niri configuration for DMS
├── dsearch.nix              # DankSearch configuration
├── greeter.nix              # DMS greeter NixOS module
├── greeter-niri.kdl         # Custom Niri config for greeter
├── greeter-example.nix      # Example greeter configuration
├── sync-greeter-theme.sh    # Theme synchronization script
├── PLUGINS.md               # Plugin installation guide
├── THEMING.md               # Matugen theming guide
├── GREETER.md               # Greeter setup guide
└── README.md                # This file
```

## Configuration Overview

DMS is configured at the **system level** via NixOS with all features enabled.
Home-manager only manages the Niri configuration file.

**Enabled Features:**

- ✅ System Monitoring (dgop)
- ✅ File Search & Indexing (DankSearch/dsearch)
- ✅ Clipboard History Manager (cliphist)
- ✅ VPN Management Widget
- ✅ Brightness Control
- ✅ Color Picker
- ✅ Dynamic Theming (wallpaper-based via **matugen** - see THEMING.md)
- ✅ Audio Visualizer (cava)
- ✅ Calendar Integration (khal)
- ✅ System Sound Support
- ✅ Systemd service integration

## DMS Greeter

DMS includes a unified login interface (greeter) for greetd that matches the visual style of the DMS lock screen.

**Features:**

- Multi-user login support
- Session memory (remembers last session and user)
- Theme synchronization with user DMS configuration
- Support for Niri, Hyprland, Sway, and mangowc compositors

**Quick Setup:**

1. Import `greeter.nix` in your host configuration
2. Enable with `services.dms-greeter.enable = true;`
3. Configure theme sync: `services.dms-greeter.themeSyncUsers = [ "stefanmatic" ];`

See **[GREETER.md](./GREETER.md)** for detailed installation and configuration instructions.

## DankSearch (dsearch)

DankSearch provides fast file indexing and search capabilities for DMS integration.

**Features:**

- Fast file indexing with configurable depth and exclusions
- Auto-reindex on file changes
- Systemd user service (auto-starts on login)
- Configurable file size limits and worker threads
- Text file content indexing

**Configuration:**

- Located in: `user/wm/dms/dsearch.nix`
- Enabled for ZVIJER via home-manager
- Indexes: `~/.dotfiles`, home directory (with blacklist), `/etc/nixos`
- API server: `127.0.0.1:43654`

**Usage:**

```bash
# Check service status
systemctl --user status dsearch

# View logs
journalctl --user -u dsearch -f

# Force reindex
dsearch index --force

# Search files
dsearch search "pattern"
```

**Customization:**
Edit `user/wm/dms/dsearch.nix` to:

- Add/remove indexed paths
- Adjust blacklist directories
- Change file size limits
- Modify text file extensions

## System Monitoring (dgop)

dgop is a lightweight system monitoring tool providing real-time system information to DMS widgets.

**Features:**

- Single static binary with zero dependencies
- CPU, memory, disk, and network monitoring
- GPU monitoring (with nvidia-smi)
- Process management integration

**Configuration:**

- Automatically installed via DMS module
- Enabled with: `enableSystemMonitoring = true;` in DMS config
- No additional configuration needed

**Usage:**

```bash
# Check version
dgop version

# View system info
dgop system

# Start server mode (for DMS integration)
dgop server
```

**Integration:**
dgop is automatically used by DMS for:

- System resource widgets in the bar
- Process list/task manager (Mod+M)
- Performance monitoring graphs

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

- **DMS Location**: `hosts/zvijer/configuration.nix` (lines 143-163)
- **DMS Module**: `inputs.dms.nixosModules.dankMaterialShell`
- **Niri**: Enabled via `programs.niri.enable` in `hosts/_common/client.nix`
- **Utilities**: `cliphist`, `grimblast` for clipboard and screenshots

### Home Manager (user-level)

- **Location**: `home/stefanmatic.nix` imports `user/wm/dms/dms.nix`
- **Purpose**: Only manages Niri `config.kdl` file and DMS config structure
- **Theming**: Handled by matugen (not stylix)

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
- [DMS Greeter Docs](https://github.com/AvengeMedia/DankMaterialShell/tree/master/quickshell/Modules/Greetd)
- [Niri Compositor](https://github.com/YaLTeR/niri)
- **[GREETER.md](./GREETER.md)** - Local greeter setup guide
- **[PLUGINS.md](./PLUGINS.md)** - Plugin installation guide
- **[THEMING.md](./THEMING.md)** - Matugen theming guide
