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
    ../_common/client.nix
    ./packages.nix # T14-specific system packages
    # Import DMS NixOS module
    inputs.dms.nixosModules.dank-material-shell
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

    # Bootloader configuration
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Syncthing - system service for user
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
          "KeePass" = {
            path = "/home/${userSettings.username}/KeePass";
            devices = [ "unraid" ];
            id = "72iax-2g67s";
          };
          "Desktop" = {
            path = "/home/${userSettings.username}/Desktop";
            devices = [ "unraid" ];
            id = "b4w9b-c7epm";
          };
          "Documents" = {
            path = "/home/${userSettings.username}/Documents";
            devices = [ "unraid" ];
            id = "zmgjt-pjaqa";
          };
          "Pictures" = {
            path = "/home/${userSettings.username}/Pictures";
            devices = [ "unraid" ];
            id = "bnzvt-hpsu6";
          };
          "Videos" = {
            path = "/home/${userSettings.username}/Videos";
            devices = [ "unraid" ];
            id = "uzfcf-ijz7p";
          };
          "Scripts" = {
            path = "/home/${userSettings.username}/Scripts";
            devices = [ "unraid" ];
            id = "udqbf-4zpw3";
          };
          "Workspace" = {
            path = "/home/${userSettings.username}/Workspace";
            devices = [ "unraid" ];
            id = "cypve-yruqr";
          };
        };
      };
    };

    # TeamViewer remote desktop service
    services.teamviewer.enable = true;

    # OBS Studio with plugins (system-level for proper integration)
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

    # Enable Niri wayland compositor
    programs.niri = {
      enable = true;
    };

    # DankMaterialShell - system-level installation
    programs.dank-material-shell = {
      enable = true;

      # Systemd service for auto-start
      systemd = {
        enable = true;
        restartIfChanged = true;
      };

      # Core features
      # enableSystemMonitoring requires dgop package which is not available
      enableSystemMonitoring = false;
      enableVPN = true; # VPN management widget
      enableDynamicTheming = true; # Wallpaper-based theming (matugen)
      enableAudioWavelength = true; # Audio visualizer (cava)
      enableCalendarEvents = true; # Calendar integration (khal)
      # Note: enableClipboard, enableColorPicker, enableBrightnessControl, enableSystemSound
      # are now built-in to DMS and no longer need to be specified
    };

    # GNOME keyring disabled - using KeePassXC Secret Service instead
    services.gnome.gnome-keyring.enable = false;

    # XDG Desktop Portal - following niri's recommended configuration
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gnome
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
      ];
      config.common = {
        default = [
          "gnome"
          "gtk"
        ];
        "org.freedesktop.impl.portal.Access" = [ "gtk" ];
        "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
        # Secret Service handled by KeePassXC (not via portal)
      };
    };
  };
}
