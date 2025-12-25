{ config, pkgs, lib, inputs, ... }:

let
  env = import ./env.nix {inherit pkgs; };
  inherit (env) systemSettings userSettings;
  customPkgs = import ../../pkgs { inherit pkgs; };
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

    # Bootloader configuration
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    environment.systemPackages = with pkgs; [
      unstable.cloudflare-warp
      customPkgs.select-browser
      #customPkgs.nordvpn

      libreoffice-qt6-fresh

      unstable.claude-code

      ghostty
      fastfetch
      viu
      mpv
      timg

      #things for niri
      fuzzel

    ];

    services.teamviewer.enable = true;

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
          #"Desktop" = {
          #  path = "/home/${userSettings.username}/Desktop";
          #  devices = [ "unraid" ];
          #  id = "b4w9b-c7epm";
          #};
          #"Documents" = {
          #  path = "/home/${userSettings.username}/Documents";
          #  devices = [ "unraid" ];
          #  id = "zmgjt-pjaqa";
          #};
          #"Pictures" = {
          #  path = "/home/${userSettings.username}/Pictures";
          #  devices = [ "unraid" ];
          #  id = "bnzvt-hpsu6";
          #};
          #"Videos" = {
          #  path = "/home/${userSettings.username}/Videos";
          #  devices = [ "unraid" ];
          #  id = "uzfcf-ijz7p";
          #};
          "Scripts" = {
            path = "/home/${userSettings.username}/Scripts";
            devices = [ "unraid" ];
            id = "udqbf-4zpw3";
          };
          #"Workspace" = {
          #  path = "/home/${userSettings.username}/Workspace";
          #  devices = [ "unraid" ];
          #  id = "cypve-yruqr";
          #};
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

    programs.niri = {
      enable = true;
    };

    programs.dms-shell = {
      enable = true;

      systemd = {
        enable = true;             # Systemd service for auto-start
        restartIfChanged = true;   # Auto-restart dms.service when dms-shell changes
      };

      # Core features
      enableSystemMonitoring = true;     # System monitoring widgets (dgop)
      enableClipboard = true;            # Clipboard history manager
      enableVPN = true;                  # VPN management widget
      enableDynamicTheming = true;       # Wallpaper-based theming (matugen)
      enableAudioWavelength = true;      # Audio visualizer (cava)
      enableCalendarEvents = true;       # Calendar integration (khal)
    };
  };
}
