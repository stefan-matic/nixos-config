# DMS Greeter Setup Guide

This guide covers the installation and configuration of DMS Greeter, a unified login interface for greetd that matches the DMS lock screen aesthetic.

## Overview

DMS Greeter provides:
- Multi-user login capabilities
- Session memory (remembers last selected session and user)
- Theme synchronization with your user DMS configuration
- Support for multiple compositors (Niri, Hyprland, Sway, mangowc)
- Consistent visual style with DMS lock screen

## Files in this Directory

- `greeter.nix` - NixOS module for DMS greeter configuration
- `greeter-niri.kdl` - Custom Niri compositor configuration for greeter
- `sync-greeter-theme.sh` - Script to synchronize themes from user to greeter
- `GREETER.md` - This documentation file

## Installation

### Step 1: Import the Greeter Module

Edit your host configuration (e.g., `hosts/zvijer/configuration.nix`):

```nix
{
  imports = [
    # ... other imports ...
    ../../user/wm/dms/greeter.nix
  ];
}
```

### Step 2: Enable and Configure the Greeter

Add the following configuration to your host config:

```nix
{
  # Enable DMS greeter
  services.dms-greeter = {
    enable = true;
    compositor = "niri";  # or "hyprland", "sway", "mangowc"

    # Use custom Niri config for greeter
    niriConfig = builtins.readFile ../../user/wm/dms/greeter-niri.kdl;

    # Enable automatic theme synchronization
    enableThemeSync = true;
    themeSyncUsers = [ "stefanmatic" ];  # Add users whose themes should sync
  };
}
```

### Step 3: Rebuild System

```bash
sudo nixos-rebuild switch --flake ~/.dotfiles#ZVIJER
```

## Theme Synchronization

### Automatic Sync (Recommended)

The module includes automatic theme synchronization via systemd service. When enabled with `enableThemeSync = true`, it will:

1. Create symlinks from user configs to `/var/cache/dms-greeter`
2. Set up proper ACL permissions
3. Sync wallpapers, quickshell config, and matugen themes

### Manual Sync

If you need to manually sync themes or the automatic sync isn't working:

```bash
sudo ./sync-greeter-theme.sh stefanmatic
```

This script:
- Adds your user to the `greeter` group
- Sets minimal ACL permissions on parent directories
- Creates symlinks for:
  - `~/.config/quickshell` → `/var/cache/dms-greeter/quickshell`
  - `~/.local/share/wallpapers` → `/var/cache/dms-greeter/wallpapers`
  - `~/.config/matugen` → `/var/cache/dms-greeter/matugen`

## Compositor Configuration

### Using Niri (Default)

The included `greeter-niri.kdl` provides a minimal, clean configuration suitable for a login screen:

- Centered layout with 50% default column width
- Essential DMS keybindings (Mod+Space for spotlight)
- Audio and brightness controls
- Dark theme preference
- Rounded corners and transparency

### Custom Niri Configuration

To customize the Niri config for greeter:

1. Edit `user/wm/dms/greeter-niri.kdl`
2. Update your host config to reference it:
   ```nix
   services.dms-greeter.niriConfig = builtins.readFile ../../user/wm/dms/greeter-niri.kdl;
   ```
3. Rebuild: `sudo nixos-rebuild switch --flake ~/.dotfiles`

### Using Hyprland

For Hyprland compositor:

```nix
services.dms-greeter = {
  enable = true;
  compositor = "hyprland";
  hyprlandConfig = ''
    # Your custom Hyprland config for greeter
    monitor=,preferred,auto,1
    # ... more config ...
  '';
};
```

## Architecture

### System-Level Components

The greeter is configured at the system level because:
- greetd is a system service that starts before user sessions
- Requires access to PAM for authentication
- Needs to manage user sessions and session selection
- Runs as the `greeter` system user

### File Locations

- **Greeter binary**: Provided by DMS flake input
- **Compositor configs**: `/etc/greetd/dms-{niri,hypr}.conf`
- **Theme cache**: `/var/cache/dms-greeter/`
- **Greeter user home**: Managed by greetd

### How It Works

1. System boots and starts greetd service
2. greetd launches DMS greeter with chosen compositor
3. Greeter reads themes from `/var/cache/dms-greeter/`
4. User logs in, greeter starts their session
5. Greeter remembers session choice for next login

## Per-Host Configuration

### Example: ZVIJER (Desktop)

```nix
# hosts/zvijer/configuration.nix
{
  imports = [ ../../user/wm/dms/greeter.nix ];

  services.dms-greeter = {
    enable = true;
    compositor = "niri";
    niriConfig = builtins.readFile ../../user/wm/dms/greeter-niri.kdl;
    enableThemeSync = true;
    themeSyncUsers = [ "stefanmatic" ];
  };
}
```

### Example: T14 (Laptop)

```nix
# hosts/t14/configuration.nix
{
  imports = [ ../../user/wm/dms/greeter.nix ];

  services.dms-greeter = {
    enable = true;
    compositor = "niri";
    niriConfig = builtins.readFile ../../user/wm/dms/greeter-niri.kdl;
    enableThemeSync = true;
    themeSyncUsers = [ "stefanmatic" ];
  };
}
```

## Troubleshooting

### Greeter Not Starting

Check greetd service status:
```bash
systemctl status greetd
journalctl -u greetd -f
```

### Themes Not Syncing

1. Check ACL permissions:
   ```bash
   getfacl /home/stefanmatic/.config/quickshell
   ```

2. Verify symlinks exist:
   ```bash
   ls -la /var/cache/dms-greeter/
   ```

3. Run manual sync:
   ```bash
   sudo ./sync-greeter-theme.sh stefanmatic
   ```

4. Check theme sync service:
   ```bash
   systemctl status dms-greeter-theme-sync
   ```

### Greeter Shows Wrong Theme

1. Ensure theme files are accessible:
   ```bash
   sudo -u greeter ls /var/cache/dms-greeter/
   ```

2. Check that symlinks point to correct locations:
   ```bash
   readlink -f /var/cache/dms-greeter/quickshell
   ```

3. Restart greetd:
   ```bash
   sudo systemctl restart greetd
   ```

### Custom PAM Configuration

If you need custom PAM settings, the greeter uses the `greetd` PAM service. Check `/etc/pam.d/greetd`.

### Session Selection Issues

The greeter remembers the last selected session in its config. To reset:
```bash
sudo rm -f /var/cache/dms-greeter/.config/dms-greeter/session.conf
sudo systemctl restart greetd
```

## Environment Variables

You can override the cache directory location:

```bash
# In greeter environment
DMS_GREET_CFG_DIR=/custom/path
```

Or use the CLI flag:
```bash
dms-greeter --cache-dir /custom/path --command niri
```

## Advanced Usage

### Running Greeter Manually

For testing or debugging:

```bash
# Using wrapper
dms-greeter --command niri

# Direct quickshell
DMS_RUN_GREETER=1 quickshell
```

### Session Configuration

Available sessions are detected from `/usr/share/wayland-sessions/` and `/usr/share/xsessions/`.

Ensure your desktop files are properly installed:
```bash
ls /usr/share/wayland-sessions/
```

## Integration with DMS

The greeter integrates seamlessly with DMS:

1. **Visual Consistency**: Uses same themes, wallpapers, and Material Design style
2. **Lock Screen Parity**: Matches the DMS lock screen aesthetic
3. **IPC Control**: DMS IPC commands work in greeter session
4. **Theme Inheritance**: Automatically picks up theme changes from user config

## Related Documentation

- [DMS README](./README.md) - Main DMS configuration
- [DMS THEMING](./THEMING.md) - Theme customization guide
- [DMS PLUGINS](./PLUGINS.md) - Plugin configuration
- [Official DMS Greeter Docs](https://github.com/AvengeMedia/DankMaterialShell/tree/master/quickshell/Modules/Greetd)

## Contributing

When updating greeter configuration:

1. Test on your local system first
2. Ensure themes sync properly for all configured users
3. Verify both automatic and manual sync methods work
4. Document any new configuration options
5. Update this guide if adding new features
