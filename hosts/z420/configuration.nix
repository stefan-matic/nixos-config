{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  env = import ./env.nix { inherit pkgs; };
  inherit (env) systemSettings userSettings;
in

{
  imports = [
    ./hardware-configuration.nix
    ../_common/server.nix
  ];

  options = {
    userSettings = lib.mkOption {
      type = lib.types.attrs;
      default = userSettings;
      description = "User settings including username";
    };

    systemSettings = lib.mkOption {
      type = lib.types.attrs;
      default = systemSettings;
      description = "System settings including hostname";
    };
  };

  config = {
    # Pass settings to child modules
    _module.args = {
      inherit systemSettings userSettings;
    };

    # Allow remote deployment
    nix.settings.trusted-users = [ "root" "stefanmatic" ];

    # Boot configuration
    boot.loader.grub.enable = true;
    boot.loader.grub.device = "/dev/sdb";

    # Firewall - server ports
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # SSH
        9443 # portainer
        80
        443
        3306 # mariadb
        8080
        2022 # pterodactyl_Wings
      ];
      allowedTCPPortRanges = [
        {
          from = 55550;
          to = 55555;
        } # Game server ports
      ];
      allowedUDPPortRanges = [
        {
          from = 55550;
          to = 55555;
        } # Game server ports
      ];
    };

    # Syncthing for file sync
    services.syncthing = {
      enable = true;
      user = userSettings.username;
      dataDir = "/home/${userSettings.username}/.config/syncthing";
      configDir = "/home/${userSettings.username}/.config/syncthing";
      settings = {
        gui = {
          theme = "dark";
          user = userSettings.username;
        };
        devices = {
          unraid = {
            id = "2T25XJC-SXWEDMA-DF4P57K-55AQCXQ-2MYHHLJ-IXF24KU-HNMUWRN-4W2R3AY";
          };
        };
        folders = {
          "dotfiles" = {
            path = "/home/${userSettings.username}/";
            devices = [ "unraid" ];
            id = "dotfiles";
          };
        };
      };
    };
  };
}
