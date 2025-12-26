{ config, pkgs, ... }:

{
  programs.niri.config = ''
    // Niri configuration for ZVIJER (57" ultrawide)
    // This config follows DMS official documentation:
    // https://danklinux.com/docs/dankmaterialshell/compositors

    // Spawn DMS at startup
    spawn-at-startup "dms" "run"

    // Clipboard history
    spawn-at-startup "bash" "-c" "wl-paste --watch cliphist store &"

    // Startup applications
    spawn-at-startup "keepassxc"
    spawn-at-startup "viber"
    spawn-at-startup "slack"
    spawn-at-startup "google-chrome-stable"

    // Input configuration
    input {
      keyboard {
        numlock
      }
    }

    // Environment variables
    environment {
      XDG_CURRENT_DESKTOP "niri"
      QT_QPA_PLATFORM "wayland"
      ELECTRON_OZONE_PLATFORM_HINT "wayland"
      QT_QPA_PLATFORMTHEME "gtk3"
      QT_QPA_PLATFORMTHEME_QT6 "gtk3"
      NIXOS_OZONE_WL "1"
    }

    // Layout configuration optimized for 57" ultrawide
    layout {
      center-focused-column "never"
      // Default to 1/3 width for 3-column layout on ultrawide
      default-column-width { proportion 0.33; }
      preset-column-widths {
        proportion 0.25
        proportion 0.33
        proportion 0.5
        proportion 0.66
        proportion 0.75
      }
      // Focus new windows instead of columns
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

    // Terminal windows - open below current window (horizontal split)
    window-rule {
      match app-id="com.mitchellh.ghostty"
      match app-id="kitty"
      match app-id="Alacritty"
      open-on-output "eDP-1"
      default-column-width { proportion 0.33; }
    }

    // KeePassXC - tiled window at 20% width
    window-rule {
      match app-id="org.keepassxc.KeePassXC"
      default-column-width { proportion 0.20; }
    }

    // Viber - tiled window at 20% width (will stack with Slack)
    window-rule {
      match app-id="com.viber.Viber"
      default-column-width { proportion 0.20; }
      block-out-from "screencast"
    }

    // Slack - tiled window at 20% width (will stack with Viber)
    window-rule {
      match app-id="Slack"
      default-column-width { proportion 0.20; }
    }

    // Chrome - tiled window
    window-rule {
      match app-id="google-chrome"
      default-column-width { proportion 0.33; }
    }

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
      Mod+E { spawn "nautilus"; }

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

      // Mouse horizontal scrolling - Mod+Horizontal Scroll to navigate columns (one at a time)
      Mod+WheelScrollRight cooldown-ms=150 { focus-column-right; }
      Mod+WheelScrollLeft cooldown-ms=150 { focus-column-left; }

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

      // Screenshot
      Print { spawn "sh" "-c" "grimblast copy area"; }
      Ctrl+Shift+X { spawn "sh" "-c" "grimblast copy area"; }

      // Niri essentials
      Mod+Shift+Slash { show-hotkey-overlay; }
      Mod+Shift+E { quit; }
      Mod+Tab { toggle-overview; }
      Mod+O { toggle-overview; }

      // Window resizing
      Mod+R { switch-preset-column-width; }
      Mod+F { maximize-column; }
      Mod+Shift+F { fullscreen-window; }

      // Floating windows
      Mod+Shift+Space { toggle-window-floating; }
      Mod+Escape { switch-focus-between-floating-and-tiling; }

      // Focus monitors (using Ctrl instead of Mod to avoid DMS conflicts)
      Mod+Ctrl+H { focus-monitor-left; }
      Mod+Ctrl+L { focus-monitor-right; }

      // Move to monitors
      Mod+Ctrl+Shift+H { move-column-to-monitor-left; }
      Mod+Ctrl+Shift+L { move-column-to-monitor-right; }

      // Consume/expel windows (smart directional - combines both operations)
      Mod+BracketLeft { consume-or-expel-window-left; }
      Mod+BracketRight { consume-or-expel-window-right; }

      // Cycle through preset widths for ultrawide
      Mod+Equal { set-column-width "+10%"; }
      Mod+Minus { set-column-width "-10%"; }
    }

    // Prefer dark theme
    prefer-no-csd true
  '';
}
