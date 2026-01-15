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
