{
  config,
  pkgs,
  lib,
  ...
}:

let
  # Import common Niri configuration builder
  common = import ./common.nix { inherit config pkgs lib; };

  # Laptop-specific configuration (t14, starlabs)
  niriConfig = common.mkNiriConfig {
    deviceType = "laptop";

    # Laptop has regular steam (not steam-fix)
    extraStartupApps = [ "steam" ];

    # External monitor above laptop display (centered)
    outputConfig = ''
      output "HDMI-A-1" {
        mode "3840x2160@59.997"
        scale 1.25
        position x=0 y=0
      }

      output "eDP-1" {
        position x=768 y=1728
      }
    '';

    # No named workspaces for laptop
    # Named workspaces for ZVIJER
    workspaceConfig = ''
      workspace "main" {
      }

      workspace "work" {
      }

      workspace "chats" {
      }

      workspace "windows" {
      }'';

    # 2-column layout optimized for laptop screen
    defaultColumnWidth = "0.5";
    presetColumnWidths = [
      "0.33"
      "0.5"
      "0.66"
      "0.75"
    ];

    # Laptop window rules
    extraWindowRules = ''
      // MPV from yazi - floating window for video/GIF playback
      window-rule {
        match title="yazi-mpv"
        open-floating true
        default-column-width { fixed 800; }
        default-window-height { fixed 450; }
      }

      window-rule {
        match at-startup=true app-id="firefox"
        open-on-workspace "work"
      }

      window-rule {
        match at-startup=true app-id="Slack"
        open-on-workspace "chats"
      }

      window-rule {
        match at-startup=true app-id="ViberPC"
        //default-column-width { proportion 0.20; }
        open-on-workspace "chats"
      }

      window-rule {
        match at-startup=true app-id="AFFiNE"
        open-on-workspace "chats"
      }

      // Winboat rdp
      window-rule {
        match app-id="winboat"
        open-on-workspace "windows"
      }
      window-rule {
        match app-id="xfreerdp"
        open-on-workspace "windows"
      }

    '';

    # No extra keybindings needed for laptop (no multi-monitor)
    extraKeybindings = ''
      // Mouse horizontal scrolling - Mod+Horizontal Scroll to navigate columns (one at a time)
      Mod+WheelScrollRight cooldown-ms=150 { focus-column-right; }
      Mod+WheelScrollLeft cooldown-ms=150 { focus-column-left; }

      // Mouse wheel for workspace navigation
      Mod+WheelScrollDown cooldown-ms=150{ focus-workspace-down; }
      Mod+WheelScrollUp cooldown-ms=150 { focus-workspace-up; }

    '';

    # Enable touchpad for laptop
    enableTouchpad = true;
  };

in
{
  # Niri configuration for laptops (t14, starlabs)
  # Single screen, optimized for portability
  # DMS itself is installed at system-level
  # DMS will dynamically create and manage files in ~/.config/niri/dms/
  # https://github.com/YaLTeR/niri/wiki/Getting-Started

  home.file.".config/niri/config.kdl".text = niriConfig;

  # DMS Plugin Configurations
  home.file.".config/DankMaterialShell/plugins/NixMonitor/config.json".source =
    ../dms/dms-plugins/nixMonitor-config.json;
}
