# DMS Theming with Matugen

DankMaterialShell uses **matugen** for dynamic theming based on your wallpaper. This replaces stylix which was previously used for Hyprland.

## How Matugen Works

Matugen automatically:
1. Analyzes your wallpaper's color palette
2. Generates a Material Design 3 color scheme
3. Applies colors to DMS components
4. Updates terminal, GTK, and Qt applications

## Configuration

Matugen is enabled by default when you enable DMS dynamic theming:

```nix
programs.dankMaterialShell = {
  enableDynamicTheming = true;  # Enables matugen
};
```

This is configured in: `hosts/zvijer/configuration.nix:159`

## Changing Wallpapers

Use the DMS wallpaper browser to change wallpapers and automatically update the theme:

```bash
# Keybinding: Mod+Y
# Or via IPC:
dms ipc call dankdash wallpaper
```

When you select a new wallpaper, matugen will:
- Extract the dominant colors
- Generate a cohesive color scheme
- Update all DMS components in real-time
- Persist the theme across reboots

## Manual Theme Configuration

Matugen generates colors in `~/.config/niri/dms/colors.kdl` which are included in your Niri config.

You can manually edit this file if needed, but changes will be overwritten when you change wallpapers.

## Color Scheme Files

Matugen stores generated themes in:
- `~/.config/matugen/` - Main configuration
- `~/.config/niri/dms/colors.kdl` - Niri-specific colors

## Troubleshooting

### Theme not updating after wallpaper change
```bash
# Restart DMS
systemctl --user restart dms
```

### Colors look wrong
1. Ensure the wallpaper has good color variety
2. Try a different wallpaper
3. Check matugen logs: `journalctl --user -u dms | grep matugen`

## Integration with Other Apps

Matugen can theme more than just DMS:
- GTK applications (via generated gtk.css)
- Qt applications (when QT_QPA_PLATFORMTHEME is set correctly)
- Terminal emulators (when supported)

The DMS module handles this integration automatically.

## References

- [Matugen GitHub](https://github.com/InioX/matugen)
- [Material Design 3 Colors](https://m3.material.io/styles/color/overview)
- [DMS Theming Docs](https://danklinux.com/docs/dankmaterialshell/theming)
