{
  config,
  pkgs,
  lib,
  ...
}:

# Common Niri configuration builder for DMS integration
# This module exports a function to generate Niri configs with device-specific overrides

{
  # Main config builder function
  # Takes an attrset with device-specific configuration
  mkNiriConfig =
    {
      # Device identification
      deviceType ? "desktop", # "desktop" or "laptop"

      # Startup applications (additional device-specific apps)
      extraStartupApps ? [ ],

      # Monitor/output configuration (KDL text)
      outputConfig ? "",

      # Workspaces configuration (KDL text)
      workspaceConfig ? "",

      # Layout configuration
      defaultColumnWidth ? "0.5",
      presetColumnWidths ? [
        "0.33"
        "0.5"
        "0.66"
        "0.75"
      ],

      # Window rules (additional device-specific rules as KDL text)
      extraWindowRules ? "",

      # Keybindings (additional device-specific bindings as KDL text)
      extraKeybindings ? "",

      # Input configuration
      enableTouchpad ? false,
    }:

    let
      # Common startup applications for all devices
      commonStartupApps = [
        "keepassxc"
        "slack"
        "google-chrome-stable"
        "firefox"
        "code"
        "winboat"
        "affine"
        "viber"
      ];

      # All startup apps combined
      allStartupApps = commonStartupApps ++ extraStartupApps;

      # Generate spawn-at-startup lines
      startupAppsKdl = lib.concatMapStringsSep "\n    " (
        app: "spawn-at-startup \"${app}\""
      ) allStartupApps;

      # Touchpad config if enabled
      touchpadConfig = lib.optionalString enableTouchpad ''

        // Touchpad configuration
        touchpad {
          tap
          natural-scroll
          dwt
          dwtp
        }'';

      # Format preset widths for KDL
      presetWidthsKdl = lib.concatMapStringsSep "\n        " (
        width: "proportion ${width}"
      ) presetColumnWidths;

    in
    ''
      // Niri configuration for DankMaterialShell
      // This config follows DMS official documentation:
      // https://danklinux.com/docs/dankmaterialshell/compositors

      // Include DMS config files (colors, layout, alttab, binds)
      include "dms/colors.kdl"
      include "dms/layout.kdl"
      include "dms/alttab.kdl"
      include "dms/binds.kdl"
      include "dms/cursor.kdl"

      // Spawn DMS at startup
      spawn-at-startup "dms" "run"

      // Clipboard history
      spawn-at-startup "bash" "-c" "wl-paste --watch cliphist store &"

      ${workspaceConfig}

      // Startup applications
      ${startupAppsKdl}

      // Input configuration
      input {
        //focus-follows-mouse
        keyboard {
          xkb {
            // English US, Serbian Latin, Serbian Cyrillic
            layout "us,rs,rs"
            variant ",latin,"
            // Switch layouts with Alt+Shift
            options "grp:alt_shift_toggle"
          }
          numlock
        }${touchpadConfig}
      }

      ${outputConfig}

      // Environment variables
      environment {
        XDG_CURRENT_DESKTOP "niri"
        QT_QPA_PLATFORM "wayland"
        ELECTRON_OZONE_PLATFORM_HINT "wayland"
        QT_QPA_PLATFORMTHEME "kde"
        NIXOS_OZONE_WL "1"
      }

      // Layout configuration
      layout {
        center-focused-column "never"
        default-column-width { proportion ${defaultColumnWidth}; }
        preset-column-widths {
          ${presetWidthsKdl}
        }
        focus-ring {
          width 2
        }
      }

      // Layer rules for DMS integration
      layer-rule {
        match namespace="^quickshell$"
        place-within-backdrop true
      }

      layer-rule {
        match namespace="dms:blurwallpaper"
        place-within-backdrop true
      }

      // Window rules for DMS
      window-rule {
        match app-id=r#"org.quickshell$"#
        open-floating true
      }

      // GNOME apps styling
      window-rule {
        match app-id=r#"^org\.gnome\."#
        draw-border-with-background false
        geometry-corner-radius 12
        clip-to-geometry true
      }

      // Terminal apps - no border background
      window-rule {
        match app-id=r#"^org\.wezfurlong\.wezterm$"#
        match app-id="Alacritty"
        match app-id="zen"
        match app-id="com.mitchellh.ghostty"
        match app-id="kitty"
        draw-border-with-background false
      }

      // Inactive windows opacity
      window-rule {
        match is-active=false
        opacity 0.9
      }

      // Default rounded corners
      window-rule {
        geometry-corner-radius 12
        clip-to-geometry true
      }

      // Ghostty terminal - open at half screen height
      window-rule {
        match app-id="com.mitchellh.ghostty"
        default-column-width { proportion ${defaultColumnWidth}; }
        default-window-height { proportion 0.5; }
      }

      // Other terminals
      window-rule {
        match app-id="kitty"
        match app-id="Alacritty"
        default-column-width { proportion ${defaultColumnWidth}; }
      }

      // Select-browser dialog - small floating window
      window-rule {
        match app-id="org.kde.kdialog"
        match title="Select your browser"
        open-floating true
        default-column-width { fixed 200; }
        default-window-height { fixed 300; }
      }

      // KCalc - floating calculator
      window-rule {
        match app-id="org.kde.kcalc"
        open-floating true
        default-column-width { fixed 400; }
        default-window-height { fixed 550; }
      }

      // RustDesk - floating remote desktop window
      window-rule {
        match app-id="rustdesk"
        open-floating true
        default-column-width { fixed 800; }
        default-window-height { fixed 600; }
      }

      ${extraWindowRules}

      // DMS keybindings
      binds {
        // Application Launchers
        Mod+Space hotkey-overlay-title="Application Launcher" {
          spawn "dms" "ipc" "call" "spotlight" "toggle";
        }
        Mod+V hotkey-overlay-title="Clipboard Manager" {
          spawn "dms" "ipc" "call" "clipboard" "toggle";
        }
        Mod+M hotkey-overlay-title="Task Manager" {
          spawn "dms" "ipc" "call" "processlist" "focusOrToggle";
        }
        Mod+Comma hotkey-overlay-title="Settings" {
          spawn "dms" "ipc" "call" "settings" "focusOrToggle";
        }
        Mod+N hotkey-overlay-title="Notification Center" {
          spawn "dms" "ipc" "call" "notifications" "toggle";
        }
        Mod+Y hotkey-overlay-title="Browse Wallpapers" {
          spawn "dms" "ipc" "call" "dankdash" "wallpaper";
        }

        // Security
        Mod+Alt+L hotkey-overlay-title="Lock Screen" {
          spawn "dms" "ipc" "call" "lock" "lock";
        }

        // DMS Notepad
        Mod+X hotkey-overlay-title="Toggle Notepad" {
          spawn "dms" "ipc" "call" "notepad" "toggle";
        }

        // Audio Controls
        XF86AudioRaiseVolume allow-when-locked=true {
          spawn "dms" "ipc" "call" "audio" "increment" "3";
        }
        XF86AudioLowerVolume allow-when-locked=true {
          spawn "dms" "ipc" "call" "audio" "decrement" "3";
        }
        XF86AudioMute allow-when-locked=true {
          spawn "dms" "ipc" "call" "audio" "mute";
        }

        // Brightness Controls
        XF86MonBrightnessUp allow-when-locked=true {
          spawn "dms" "ipc" "call" "brightness" "increment" "5" "";
        }
        XF86MonBrightnessDown allow-when-locked=true {
          spawn "dms" "ipc" "call" "brightness" "decrement" "5" "";
        }

        // Window management
        Mod+Q { close-window; }
        Mod+Return { spawn "ghostty"; }
        Mod+E { spawn "dolphin"; }
        Mod+Alt+E { spawn "nautilus"; }
        Mod+T hotkey-overlay-title="Kate Editor" { spawn "kate" "--new"; }

        // Window focus (Vim-style)
        Mod+H { focus-column-left; }
        Mod+L { focus-column-right; }
        Mod+J { focus-window-down; }
        Mod+K { focus-window-up; }

        // Arrow keys alternative
        Mod+Left { focus-column-left; }
        Mod+Right { focus-column-right; }
        Mod+Down { focus-window-down; }
        Mod+Up { focus-window-up; }

        // Window movement
        Mod+Shift+H { move-column-left; }
        Mod+Shift+L { move-column-right; }
        Mod+Shift+J { move-window-down; }
        Mod+Shift+K { move-window-up; }

        // Workspaces
        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }

        // Workspace navigation with Page Up/Down
        Mod+Page_Down { focus-workspace-down; }
        Mod+Page_Up { focus-workspace-up; }

        Mod+Shift+1 { move-column-to-workspace 1; }
        Mod+Shift+2 { move-column-to-workspace 2; }
        Mod+Shift+3 { move-column-to-workspace 3; }
        Mod+Shift+4 { move-column-to-workspace 4; }
        Mod+Shift+5 { move-column-to-workspace 5; }

        // Move column to workspace with Page Up/Down
        Mod+Shift+Page_Down { move-column-to-workspace-down; }
        Mod+Shift+Page_Up { move-column-to-workspace-up; }

        // Screenshot - select area, annotate, then save/copy
        Print { spawn "sh" "-c" "grim -g \"$(slurp)\" - | swappy -f -"; }
        Ctrl+Shift+X { spawn "sh" "-c" "grim -g \"$(slurp)\" - | swappy -f -"; }

        // Screen recording - toggle: first press selects area and starts, second press stops
        Ctrl+Shift+R { spawn "sh" "-c" "pkill -SIGINT wf-recorder || wf-recorder -g \"$(slurp)\" -f ~/Videos/recording-$(date +%Y%m%d-%H%M%S).mp4"; }

        // Niri essentials
        Mod+Shift+Slash { show-hotkey-overlay; }
        Mod+Shift+Escape { quit; }
        Mod+Tab { toggle-overview; }
        Mod+O { toggle-overview; }

        // Window resizing
        Mod+R { switch-preset-column-width; }
        Mod+F { maximize-column; }
        Mod+Shift+F { fullscreen-window; }

        // Floating windows
        Mod+Shift+Space { toggle-window-floating; }
        Mod+Escape { switch-focus-between-floating-and-tiling; }

        // Power Menu
        Mod+Shift+E hotkey-overlay-title="Power Menu" {
          spawn "dms" "ipc" "call" "powermenu" "toggle";
        }

        // Consume/expel windows (smart directional - combines both operations)
        Mod+BracketLeft { consume-or-expel-window-left; }
        Mod+BracketRight { consume-or-expel-window-right; }

        // Cycle through preset widths
        Mod+Equal { set-column-width "+10%"; }
        Mod+Minus { set-column-width "-10%"; }

        Mod+A { spawn "dms" "ipc" "call" "plugins" "toggle" "aiAssistant"; }

        ${extraKeybindings}
      }

      // Prefer dark theme
      prefer-no-csd true
    '';
}
