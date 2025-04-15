{ config, pkgs, lib, inputs, ... }:

let
  env = import ./env.nix {inherit pkgs; };
  inherit (env) systemSettings userSettings;
in

{
  imports =
    [
      ./hardware-configuration.nix
      ../_common/client.nix
      ../../system/devices/TA-p-4025w
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

    # Add required packages
    environment.systemPackages = with pkgs; [
      ghostscript
      cups-filters
      gutenprint
      gutenprintBin
    ];

    services.syncthing = {
      enable = true;
      user = "stefanmatic";  # Replace with your actual username
      dataDir = "/home/stefanmatic/.config/syncthing";  # Explicitly set the data directory
      configDir = "/home/stefanmatic/.config/syncthing";
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
            path = "/home/stefanmatic/";
            devices = [ "unraid" ];
            id = "dotfiles";
          };
          "KeePass" = {
            path = "/home/stefanmatic/KeePass";
            devices = [ "unraid" ];
            id = "72iax-2g67s";
          };
          "Desktop" = {
            path = "/home/stefanmatic/Desktop";
            devices = [ "unraid" ];
            id = "b4w9b-c7epm";
          };
          "Documents" = {
            path = "/home/stefanmatic/Documents";
            devices = [ "unraid" ];
            id = "zmgjt-pjaqa";
          };
          "Pictures" = {
            path = "/home/stefanmatic/Pictures";
            devices = [ "unraid" ];
            id = "bnzvt-hpsu6";
          };
          "Videos" = {
            path = "/home/stefanmatic/Videos";
            devices = [ "unraid" ];
            id = "uzfcf-ijz7p";
          };
          "Scripts" = {
            path = "/home/stefanmatic/Scripts";
            devices = [ "unraid" ];
            id = "udqbf-4zpw3";
          };
          "Workspace" = {
            path = "/home/stefanmatic/Workspace";
            devices = [ "unraid" ];
            id = "cypve-yruqr";
          };
        };
      };
    };

    programs.obs-studio = {
      enable = true;
      enableVirtualCamera = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
        obs-composite-blur
      ];
    };

#    # Configure CUPS
#    services.printing = {
#      enable = true;
#      drivers = with pkgs; [
#        gutenprint
#        gutenprintBin
#      ];
#      extraConf = ''
#        # Use Ghostscript for PDF rendering
#        pdftops-renderer ghostscript
#        pdftops-renderer-default ghostscript
#      '';
#      logLevel = "debug";  # Enable debug logging
#    };
#
#    services.avahi = {
#      enable = true;
#      nssmdns4 = true;
#      openFirewall = true;
#    };

    # Enable the printer
    hardware.printers.TA-p-4025w.enable = true;
  };
}
