{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

# DMS Greeter Configuration for NixOS
# This module configures greetd with dms-greeter for a unified login experience
# matching the DMS lock screen aesthetic.
#
# Usage:
#   1. Import this module in your host configuration:
#      imports = [ ../../user/wm/dms/greeter.nix ];
#
#   2. Enable the greeter:
#      services.dms-greeter.enable = true;
#
#   3. Choose compositor (niri, hyprland, sway, or mangowc):
#      services.dms-greeter.compositor = "niri";
#
#   4. Optionally customize compositor config via:
#      services.dms-greeter.niriConfig or services.dms-greeter.hyprlandConfig

with lib;

let
  cfg = config.services.dms-greeter;
in
{
  options.services.dms-greeter = {
    enable = mkEnableOption "DMS greeter for greetd";

    compositor = mkOption {
      type = types.enum [
        "niri"
        "hyprland"
        "sway"
        "mangowc"
      ];
      default = "niri";
      description = "Which compositor to use for the greeter";
    };

    niriConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Custom Niri configuration for the greeter (written to /etc/greetd/dms-niri.kdl)";
    };

    hyprlandConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Custom Hyprland configuration for the greeter (written to /etc/greetd/dms-hypr.conf)";
    };

    enableThemeSync = mkOption {
      type = types.bool;
      default = true;
      description = "Enable automatic theme synchronization from user configs to greeter";
    };

    themeSyncUsers = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [ "stefanmatic" ];
      description = "Users whose themes should be synced to the greeter";
    };
  };

  config = mkIf cfg.enable {
    # Import DMS greeter module from the DMS flake
    imports = [ inputs.dms.nixosModules.dms-greeter ];

    # Enable greetd with DMS greeter
    programs.dms-greeter = {
      enable = true;
      compositor = cfg.compositor;
    };

    # Write custom compositor configs if provided
    environment.etc."greetd/dms-niri.kdl" = mkIf (cfg.compositor == "niri" && cfg.niriConfig != "") {
      text = cfg.niriConfig;
      mode = "0644";
    };

    environment.etc."greetd/dms-hypr.conf" =
      mkIf (cfg.compositor == "hyprland" && cfg.hyprlandConfig != "")
        {
          text = cfg.hyprlandConfig;
          mode = "0644";
        };

    # Create greeter cache directory
    systemd.tmpfiles.rules = [
      "d /var/cache/dms-greeter 0755 greeter greeter -"
    ];

    # Theme synchronization setup
    # This creates symlinks from user config to greeter cache for wallpapers and themes
    systemd.services.dms-greeter-theme-sync = mkIf (cfg.enableThemeSync && cfg.themeSyncUsers != [ ]) {
      description = "Synchronize themes from users to DMS greeter";
      wantedBy = [ "multi-user.target" ];
      after = [ "local-fs.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = ''
        # Ensure greeter cache directory exists
        mkdir -p /var/cache/dms-greeter

        ${concatMapStringsSep "\n" (user: ''
          # Add user to greeter group for ACL access
          ${pkgs.acl}/bin/setfacl -m g:greeter:rx /home/${user} || true
          ${pkgs.acl}/bin/setfacl -m g:greeter:rx /home/${user}/.config || true

          # Create symlinks for DMS config
          if [ -d /home/${user}/.config/quickshell ]; then
            ln -sf /home/${user}/.config/quickshell /var/cache/dms-greeter/quickshell-${user} || true
          fi

          # Create symlinks for wallpapers
          if [ -d /home/${user}/.local/share/wallpapers ]; then
            ln -sf /home/${user}/.local/share/wallpapers /var/cache/dms-greeter/wallpapers-${user} || true
          fi

          # Create symlinks for matugen themes
          if [ -d /home/${user}/.config/matugen ]; then
            ln -sf /home/${user}/.config/matugen /var/cache/dms-greeter/matugen-${user} || true
          fi
        '') cfg.themeSyncUsers}
      '';
    };
  };
}
