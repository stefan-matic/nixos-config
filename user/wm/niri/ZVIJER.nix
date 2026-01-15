{ config, pkgs, lib, ... }:

let
  # Import common Niri configuration builder
  common = import ./common.nix { inherit config pkgs lib; };

  # ZVIJER-specific configuration
  niriConfig = common.mkNiriConfig {
    deviceType = "desktop";

    # ZVIJER has additional startup apps
    extraStartupApps = [
      "yubioath-flutter"
      "steam-fix"  # Use steam-fix instead of regular steam for ZVIJER
    ];

    # Dual monitor setup for 57" ultrawide + 34" secondary
    outputConfig = ''
    // Display configuration for dual monitor setup
    // Xiaomi 34" Monitor (DP-2) - Secondary display at top
    // Logical size: 3440/1.30 = 2646x1108
    output "DP-2" {
      mode "3440x1440@144.000"
      scale 1.30
      position x=1749 y=0
    }

    // Samsung 57" Odyssey G95NC (DP-3) - Primary display at bottom
    // Logical size: 7680/1.25 = 6144x1728
    output "DP-3" {
      mode "7680x2160@240.000"
      scale 1.25
      position x=0 y=1108
    }'';

    # Named workspaces for ZVIJER
    workspaceConfig = ''
    workspace "main" {
      // open-on-output "DP-2"
    }

    workspace "gaming" {
      // open-on-output "DP-2"
    }

    workspace "windows" {
      // open-on-output "DP-2"
    }'';

    # 3-column layout optimized for ultrawide
    defaultColumnWidth = "0.33";
    presetColumnWidths = [ "0.25" "0.33" "0.5" "0.66" "0.75" ];

    # ZVIJER-specific window rules
    extraWindowRules = ''
    // KeePassXC - tiled window at 20% width on Xiaomi monitor
    window-rule {
      match app-id="org.keepassxc.KeePassXC"
      default-column-width { proportion 0.20; }
      open-on-output "DP-2"
    }

    window-rule {
      match app-id="com.yubico.yubioath"
      default-column-width { proportion 0.20; }
      open-on-output "DP-2"
    }

    // Steam (uses XWayland via xwayland-satellite - run 'xwayland-restart' if it won't launch)
    window-rule {
      match at-startup=true app-id="steam"
      open-on-workspace "gaming"
    }

    // Winboat rdp
    window-rule {
      match app-id="xfreerdp"
      open-on-workspace "windows"
    }

    // Viber - tiled window at 20% width (will stack with Slack)
    window-rule {
      match at-startup=true app-id="ViberPC"
      default-column-width { proportion 0.20; }
      block-out-from "screencast"
    }

    // Slack - tiled window at 20% width (will stack with Viber)
    window-rule {
      match at-startup=true app-id="Slack"
      default-column-width { proportion 0.20; }
      open-on-workspace "gaming"
    }

    // Chrome - tiled window
    window-rule {
      match app-id="google-chrome"
      default-column-width { proportion 0.33; }
    }'';

    # ZVIJER-specific keybindings (multi-monitor navigation)
    extraKeybindings = ''
    // Focus monitors (using Ctrl instead of Mod to avoid DMS conflicts)
    Mod+Ctrl+H { focus-monitor-left; }
    Mod+Ctrl+L { focus-monitor-right; }

    // Move to monitors
    Mod+Ctrl+Shift+H { move-column-to-monitor-left; }
    Mod+Ctrl+Shift+L { move-column-to-monitor-right; }

    // Mouse horizontal scrolling - Mod+Horizontal Scroll to navigate columns (one at a time)
    Mod+WheelScrollRight cooldown-ms=150 { focus-column-right; }
    Mod+WheelScrollLeft cooldown-ms=150 { focus-column-left; }

    // Mouse wheel for workspace navigation
    Mod+WheelScrollDown cooldown-ms=150{ focus-workspace-down; }
    Mod+WheelScrollUp cooldown-ms=150 { focus-workspace-up; }'';

    # No touchpad on desktop
    enableTouchpad = false;
  };

in {
  # Niri configuration file for DMS integration (ZVIJER desktop)
  # DMS itself is installed at system-level in hosts/zvijer/configuration.nix
  # DMS will dynamically create and manage files in ~/.config/niri/dms/
  # https://github.com/YaLTeR/niri/wiki/Getting-Started

  home.file.".config/niri/config.kdl".text = niriConfig;

  # DMS Plugin Configurations
  home.file.".config/DankMaterialShell/plugins/NixMonitor/config.json".source =
    ../dms/dms-plugins/nixMonitor-config.json;
}
