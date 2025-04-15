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


    # Printing
    services.printing = {
      enable = true;
      drivers = [ pkgs.cups-kyocera ]; # Add Kyocera drivers if available in nixpkgs
    };

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    # Create a package containing both the PPD file and the Kyocera filters
    nixpkgs.config.packageOverrides = pkgs: {
      kyocera-drivers = pkgs.runCommand "kyocera-drivers" {} ''
        mkdir -p $out/share/cups/model
        mkdir -p $out/lib/cups/filter

        # Copy your PPD file
        cp ${../../system/drivers/Matic-Printer.ppd} $out/share/cups/model/TA-p-4025w.ppd
        chmod 644 $out/share/cups/model/TA-p-4025w.ppd

        # Copy Kyocera filter files (you need to adjust the path to where you extracted the drivers)
        cp /path/to/kyocera/drivers/kyofilter_* $out/lib/cups/filter/
        chmod 755 $out/lib/cups/filter/*
      '';
    };

    # Make sure the package is installed
    environment.systemPackages = [ pkgs.kyocera-drivers ];

    # Create a custom systemd service to set up the printer after boot
    systemd.services.setup-matic-printer = {
      # ... other settings as before ...
      script = ''
        sleep 5
        /run/current-system/sw/bin/lpadmin -p Matic-Printer \
          -v http://10.100.10.251:631/ \
          -m drv:///sample.drv/generic.ppd \
          -L "Home" \
          -E
        /run/current-system/sw/bin/lpoptions -d Matic-Printer
        /run/current-system/sw/bin/lpoptions -p Matic-Printer -o PageSize=A4
      '';
    };
  };
}
