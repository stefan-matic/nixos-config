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
  customPkgs = import ../../pkgs { inherit pkgs; };
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

    boot.loader.grub.enable = true;
    boot.loader.grub.device = "/dev/sdb";
    boot.loader.grub.useOSProber = true;

    services.desktopManager.plasma6.enable = true;
    services.displayManager = {
      defaultSession = "plasma";
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };

    environment.systemPackages = with pkgs; [
      handbrake
    ];

    # Firewall
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [
        9443 # portainer
        80
        443 # pterodactyl_panel
        3306 # mariadb
        8080
        2022 # pterodactyl_Wings
      ];
      allowedUDPPorts = [

      ];

      allowedTCPPortRanges = [
        {
          from = 55550;
          to = 55555;
        } # Ports for game servers
      ];
      allowedUDPPortRanges = [
        {
          from = 55550;
          to = 55555;
        } # Ports for game servers
      ];
    };

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
