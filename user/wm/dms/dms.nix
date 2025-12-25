{ config, pkgs, lib, ... }:

{
  # Niri configuration file for DMS integration
  # DMS itself is installed at system-level in hosts/zvijer/configuration.nix

  home.file.".config/niri/config.kdl".text = ''
    // Niri configuration for DankMaterialShell

    // Spawn DMS at startup
    spawn-at-startup "dms" "run"

    // Environment variables
    environment {
      XDG_CURRENT_DESKTOP "niri"
      QT_QPA_PLATFORM "wayland"
      ELECTRON_OZONE_PLATFORM_HINT "auto"
      QT_QPA_PLATFORMTHEME "qt5ct"
    }

    // Layout configuration
    layout {
      gaps 8
      center-focused-column "never"

      default-column-width { proportion 0.5; }

      preset-column-widths {
        proportion 0.33
        proportion 0.5
        proportion 0.66
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

    // Window rules - Quickshell windows should float
    window-rule {
      match app-id=r#"^org\.quickshell.*$"#
      open-floating true
    }

    // DMS keybindings
    binds {
      // DMS controls
      Mod+Space { spawn "dms" "ipc" "call" "spotlight" "toggle"; }
      Mod+M { spawn "dms" "ipc" "call" "processlist" "focusOrToggle"; }
      Mod+Comma { spawn "dms" "ipc" "call" "settings" "focusOrToggle"; }
      Mod+Alt+L { spawn "dms" "ipc" "call" "lock" "lock"; }

      // Window management
      Mod+Q { close-window; }
      Mod+Return { spawn "ghostty"; }

      // Window focus (Vim-style)
      Mod+H { focus-column-left; }
      Mod+L { focus-column-right; }
      Mod+J { focus-window-down; }
      Mod+K { focus-window-up; }

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

      Mod+Shift+1 { move-column-to-workspace 1; }
      Mod+Shift+2 { move-column-to-workspace 2; }
      Mod+Shift+3 { move-column-to-workspace 3; }
      Mod+Shift+4 { move-column-to-workspace 4; }
      Mod+Shift+5 { move-column-to-workspace 5; }

      // Screenshot
      Print { spawn "sh" "-c" "grimblast copy area"; }
    }

    // Prefer dark theme
    prefer-no-csd true
  '';
}
