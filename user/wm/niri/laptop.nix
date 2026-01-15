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

    # No output config needed for laptop (single built-in display)
    outputConfig = "";

    # No named workspaces for laptop
    workspaceConfig = "";

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
      }'';

    # No extra keybindings needed for laptop (no multi-monitor)
    extraKeybindings = "";

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
