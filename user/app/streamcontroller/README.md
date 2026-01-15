# StreamController Configuration

This directory contains the managed configuration for StreamController (Stream Deck Plus control app).

## Structure

```
.
├── streamcontroller.nix    # Home-manager module
├── pages/                  # Button/page configurations
│   ├── Main.json          # Main page layout
│   └── Emoji.json         # Emoji page layout
├── settings/              # App settings
│   ├── settings.json      # General app settings
│   └── migrations.json    # Migration tracking
└── .skip-onboarding       # Skip onboarding wizard
```

## Current Button Configuration

### Main Page (Main.json)

**Keys (Buttons):**
- **0x0**: 💡 **Elgato Key Light Toggle**
  - Plugin: `de_gensyn_HomeAssistantPlugin::HomeAssistantAction`
  - Entity: `light.elgato_key_light`
  - Service: Toggle light on/off
- **0x1**: 💡 **WLED Office Light Toggle**
  - Plugin: `de_gensyn_HomeAssistantPlugin::HomeAssistantAction`
  - Entities: `light.wled_office` + `light.office_wled_segment_1`
  - Service: Toggle both WLED lights together
  - Icon: insights (inverted)
  - Label: "WLED"
- **1x0**: 🌤️ **Weather Widget**
  - Location: Banja Luka (44.7722, 17.1910)
- **2x1**: 😊 **Emoji Page Switcher**
  - Red background with emoticon icon
  - Switches to Emoji page
- **3x1**: 🎤 **Microphone Mute Toggle**
  - Plugin: `com_core447_MicMute::ToggleMute`
  - Device: "Mic" (Focusrite Scarlett 2i2)
  - Visual feedback:
    - Red background when muted
    - Black/transparent when unmuted

**Dials (Rotary Encoders):**
- **Dial 0**: Main output volume (Focusrite Scarlett Line1)
- **Dial 1**: Speakers volume (USB Audio SPDIF)
- **Dial 2**: Microphone input volume (Focusrite Scarlett Mic2)

### Emoji Page (Emoji.json)

**Keys (Buttons):**
- **0x0**: ¯\_(ツ)_/¯ **Shrug**
- **1x0**: (╯°□°)╯︵ ┻━┻ **Table Flip**
- **2x0**: ಠ_ಠ **Look of Disapproval**
- **3x0**: ( ͡° ͜ʖ ͡°) **Lenny Face**
- **1x1**: ┬─┬ノ( º _ ºノ) **Table Unflip**
- **3x1**: ⬅️ **Back to Main Page**

## Usage

This configuration is **ZVIJER-specific** and is automatically applied when you run:

```bash
home-manager switch --flake ~/.dotfiles#stefanmatic@ZVIJER
```

Files are managed as follows:
- **Page files** (`pages/*.json`): **COPIED** (not symlinked) - fully writable
- **Settings files** (`settings/*.json`): **COPIED** (not symlinked) - fully writable
- **Skip onboarding flag**: Created as empty file via symlink

**Why copied instead of symlinked?**
StreamController needs to modify these files (for backups, settings changes, etc.).
Symlinks point to read-only Nix store files, causing `PermissionError: [Errno 13]`.
Using `home.activation` script to copy files ensures they're writable.

**Location:**
- `~/.var/app/com.core447.StreamController/data/pages/` - writable copies
- `~/.var/app/com.core447.StreamController/data/settings/` - writable copies

## Updating Configuration

### After Making Changes in StreamController App

1. Make your changes in the StreamController app
2. Run the sync script to copy updated files back to dotfiles:
   ```bash
   cd ~/.dotfiles/user/app/streamcontroller
   ./sync-from-live.sh
   ```

   Or manually copy files:
   ```bash
   cp ~/.var/app/com.core447.StreamController/data/pages/*.json ~/.dotfiles/user/app/streamcontroller/pages/
   cp ~/.var/app/com.core447.StreamController/data/settings/*.json ~/.dotfiles/user/app/streamcontroller/settings/
   ```
3. Review and commit changes to git:
   ```bash
   cd ~/.dotfiles
   git diff user/app/streamcontroller/
   git add user/app/streamcontroller/
   git commit -m "Update StreamController configuration"
   ```

### To Restore Configuration

If you lose your StreamController data, simply run:

```bash
home-manager switch --flake ~/.dotfiles#stefanmatic@ZVIJER
```

This will restore your pages and settings from the dotfiles repo.

## Notes

- **Not Managed**: Plugins, icons, wallpapers, and cached data are NOT managed by this config
  - These are stored in `data/plugins/`, `data/icons/`, `data/wallpapers/`, `data/cache/`
  - StreamController will regenerate these as needed
- **StreamController Install**: StreamController itself is installed via Flatpak, not managed here
- **Host-Specific**: This config is only applied to ZVIJER (where the Stream Deck is connected)

## Flatpak Data Location

StreamController (Flatpak) stores all data in:
```
~/.var/app/com.core447.StreamController/data/
```

## Performance Optimizations

StreamController can be slow to start due to network checks (plugin store, auto-updates). The configuration includes:

**Developer Mode Enabled:**
- Disables auto-update checks on startup
- Disables plugin store update checks
- Significantly faster startup (5s vs 2-3 minutes)

**Settings in `settings.json`:**
```json
{
  "store": {
    "check-for-updates-on-startup": false
  },
  "system": {
    "developer-mode": true
  }
}
```

**Launch with `--devel` flag:**
```bash
streamcontroller --devel -b
```

## Troubleshooting

### Slow Startup (2-3 minutes)
**Cause**: Network checks for updates (GitHub CDN, Cloudflare)
**Solution**: Enable developer mode (already configured)

### Permission Errors
**Cause**: Read-only symlinks to Nix store
**Solution**: Using activation script to copy files (already implemented)

### Home Assistant Plugin Errors
**Cause**: Wrong port configuration (was 4, should be 8123)
**Solution**: Port fixed to 8123 in plugin settings

## References

- [StreamController GitHub](https://github.com/StreamController/StreamController)
- [StreamController Documentation](https://streamcontroller.core447.com/)
