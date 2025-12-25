{ config, pkgs, lib, inputs, ... }:

{
  # Import DMS home-manager module
  imports = [
    inputs.dms.homeModules.dankMaterialShell
  ];

  # DankMaterialShell configuration
  # The DMS module handles Niri integration automatically
  programs.dankMaterialShell = {
    enable = true;

    # Systemd service for auto-start
    systemd = {
      enable = true;
      restartIfChanged = true;
    };

    # Core features - all enabled by default
    enableSystemMonitoring = true;      # System monitoring widgets (dgop)
    enableClipboard = true;              # Clipboard history manager
    enableVPN = true;                    # VPN management widget
    enableBrightnessControl = true;      # Brightness/backlight support
    enableColorPicker = true;            # Color picking support
    enableDynamicTheming = true;         # Wallpaper-based theming (matugen)
    enableAudioWavelength = true;        # Audio visualizer (cava)
    enableCalendarEvents = true;         # Calendar integration (khal)
    enableSystemSound = true;            # System sound support
  };

  # Niri compositor configuration for DMS integration
  wayland.windowManager.niri = {
    settings = {
      # Spawn DMS at startup
      spawn-at-startup = [
        { command = ["dms" "run"]; }
      ];

      # Prefer dark appearance
      prefer-no-csd = true;

      # Environment variables for optimal DMS experience
      environment = {
        XDG_CURRENT_DESKTOP = "niri";
        QT_QPA_PLATFORM = "wayland";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
        QT_QPA_PLATFORMTHEME = "qt5ct";
      };

      # Layout configuration optimized for DMS
      layout = {
        gaps = 8;
        center-focused-column = "never";
        default-column-width = { proportion = 0.5; };
        preset-column-widths = [
          { proportion = 0.33; }
          { proportion = 0.5; }
          { proportion = 0.66; }
        ];
      };

      # DMS-specific layer rules
      window-rule = [
        # Quickshell windows (DMS UI elements) should float
        {
          matches = [{ app-id = "^org\\.quickshell.*$"; }];
          open-floating = true;
        }
      ];

      # DMS keybindings
      binds = with config.lib.niri.actions; {
        # DMS application launcher
        "Mod+Space".action = spawn "dms" "ipc" "call" "spotlight" "toggle";

        # DMS process list/system monitor
        "Mod+M".action = spawn "dms" "ipc" "call" "processlist" "focusOrToggle";

        # DMS settings
        "Mod+Comma".action = spawn "dms" "ipc" "call" "settings" "focusOrToggle";

        # DMS lock screen
        "Mod+Alt+L".action = spawn "dms" "ipc" "call" "lock" "lock";

        # Standard Niri keybindings
        "Mod+Q".action = close-window;
        "Mod+Return".action = spawn "ghostty";

        # Window focus
        "Mod+H".action = focus-column-left;
        "Mod+L".action = focus-column-right;
        "Mod+J".action = focus-window-down;
        "Mod+K".action = focus-window-up;

        # Window movement
        "Mod+Shift+H".action = move-column-left;
        "Mod+Shift+L".action = move-column-right;
        "Mod+Shift+J".action = move-window-down;
        "Mod+Shift+K".action = move-window-up;

        # Workspaces
        "Mod+1".action = focus-workspace 1;
        "Mod+2".action = focus-workspace 2;
        "Mod+3".action = focus-workspace 3;
        "Mod+4".action = focus-workspace 4;
        "Mod+5".action = focus-workspace 5;

        "Mod+Shift+1".action = move-column-to-workspace 1;
        "Mod+Shift+2".action = move-column-to-workspace 2;
        "Mod+Shift+3".action = move-column-to-workspace 3;
        "Mod+Shift+4".action = move-column-to-workspace 4;
        "Mod+Shift+5".action = move-column-to-workspace 5;

        # Screenshot
        "Print".action = spawn "sh" "-c" "grimblast copy area";
      };
    };
  };
}
