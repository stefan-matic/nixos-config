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

    # Boot loader configuration
    boot.loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      grub = {
        enable = true;
        devices = [ "nodev" ];
        efiSupport = true;
        useOSProber = false;
        configurationLimit = 20;
        extraEntries = ''
          menuentry "Windows 11" {
            search --fs-uuid --set=root EA7D-5648
            chainloader /EFI/Microsoft/Boot/bootmgfw.efi
          }
        '';
      };
      systemd-boot.enable = lib.mkForce false;
      timeout = 5;
    };
    # Add os-prober to detect Windows
    environment.systemPackages = with pkgs; [
      os-prober
      ntfs3g
      kdePackages.kdialog
      customPkgs.select-browser
      kdePackages.kdenlive
      veracrypt
      lutris
      wineWowPackages.stable
      winetricks
      vulkan-tools
      vulkan-loader
      vulkan-validation-layers
      amdvlk

      # Java
      #openjdk
      #jre_minimal
      #adoptopenjdk-icedtea-web
      #javaPackages.openjfx17

      quickemu

      libreoffice-qt6-fresh

      protonvpn-gui
      zoom-us

      devbox

      nodejs

      azure-cli
      azure-cli-extensions.bastion
      azure-cli-extensions.azure-firewall
      azure-cli-extensions.log-analytics
      azure-cli-extensions.log-analytics-solution
      azure-cli-extensions.monitor-control-service
      azure-cli-extensions.resource-graph
      azure-cli-extensions.scheduled-query
      azure-cli-extensions.application-insights

      claude-code

      element-desktop

      unstable.kiro

      streamdeck-ui
      customPkgs.streamdeck-plus-software
    ];

    # Add user to required groups
    users.users.${userSettings.username} = {
      extraGroups = [ "dialout" "uucp" "plugdev" "video" ];
    };

    # Add udev rules for Arduino and webcam
    services.udev.extraRules = ''
      SUBSYSTEM=="tty", ATTRS{idVendor}=="2341", ATTRS{idProduct}=="*", GROUP="dialout", MODE="0660"
      SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="*", GROUP="dialout", MODE="0660"
      SUBSYSTEM=="tty", ATTRS{idVendor}=="2a03", ATTRS{idProduct}=="*", GROUP="dialout", MODE="0660"

      # Webcam permissions
      SUBSYSTEM=="video4linux", GROUP="video", MODE="0660"
    '';

    services.syncthing = {
      enable = true;
      user = "stefanmatic";  # Replace with your actual username
      dataDir = "/home/stefanmatic/.config/syncthing";  # Explicitly set the data directory
      configDir = "/home/stefanmatic/.config/syncthing";
      extraFlags = [ "--allow-newer-config" ];
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

    # Enable the printer
    hardware.printers.TA-p-4025w.enable = true;

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    services.teamviewer.enable = true;

    # Commented out in favor of home-manager service
    #apps.deej = {
    #  enable = true;
    #  user = userSettings.username;
    #};
  };
}
