{ config, pkgs, lib, inputs, ... }:

let
  env = import ./env.nix {inherit pkgs; };
  inherit (env) systemSettings userSettings;
  customPkgs = import ../../pkgs { inherit pkgs; };

  # Import unstable nixpkgs for DMS
  unstablePkgs = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };
in

{
  imports =
    [
      ./hardware-configuration.nix
      ../_common/client.nix
      ./packages.nix  # ZVIJER-specific system packages
      ../../system/devices/TA-p-4025w
      # Import DMS NixOS module
      inputs.dms.nixosModules.dankMaterialShell
      # Import NordVPN module
      ../../modules/services/networking/nordvpn.nix
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

    # System packages for dual-boot and filesystems
    environment.systemPackages = with pkgs; [
      ntfs3g  # NTFS filesystem support for Windows partition
    ];

    # DankMaterialShell - system-level installation
    programs.dankMaterialShell = {
      enable = true;

      # Systemd service disabled - DMS is spawned by Niri instead
      systemd = {
        enable = true;
        restartIfChanged = true;
      };

      # Core features - all enabled by default
      enableSystemMonitoring = true;      # System monitoring widgets (dgop)
      enableClipboard = true;              # Clipboard history manager
      enableVPN = true;                    # VPN management widget
      enableBrightnessControl = true;      # Brightness/backlight support
      enableColorPicker = true;            # Color picking support
      enableDynamicTheming = true;         # Wallpaper-based theming (matugen)
      enableAudioWavelength = true;        # Audio visualizer (cava)
      enableCalendarEvents = true;         # Calendar integration (khal)
      enableSystemSound = true;            # System sound support
    };

    # XDG Desktop Portal for Wayland screen sharing (RustDesk, OBS, etc.)
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk  # GTK file chooser, etc.
        xdg-desktop-portal-wlr  # Screen sharing for wlroots-based compositors
      ];
      config.common = {
        default = [ "gtk" ];
        # Use wlr portal for screen capture
        "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
      };
    };

    # Create a Niri Wayland session file for display manager
    # This makes Niri appear as a proper GNOME-compatible session
    environment.etc."wayland-sessions/niri.desktop".text = ''
      [Desktop Entry]
      Name=Niri
      Comment=Niri Wayland Compositor
      Exec=niri-session
      Type=Application
      DesktopNames=GNOME
    '';

    # Enable NordVPN service
    services.nordvpn = {
      enable = true;
      package = customPkgs.nordvpn;
    };

    # Enable OpenRazer hardware daemon
    hardware.openrazer = {
      enable = true;
      users = [ userSettings.username ];
    };

    # Temporarily disabled - OpenRazer doesn't support kernel 6.18 yet
    # boot.extraModulePackages = with config.boot.kernelPackages; [
    #   openrazer
    # ];

    # Add user to required groups
    users.users.${userSettings.username} = {
      extraGroups = [ "dialout" "uucp" "plugdev" "video" "openrazer" ];
    };

    # Ensure plugdev group exists
    users.groups.plugdev = {};

    # Add udev rules for Arduino, webcam, Stream Deck, and Vial keyboard
    services.udev.extraRules = ''
      SUBSYSTEM=="tty", ATTRS{idVendor}=="2341", ATTRS{idProduct}=="*", GROUP="dialout", MODE="0660"
      SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="*", GROUP="dialout", MODE="0660"
      SUBSYSTEM=="tty", ATTRS{idVendor}=="2a03", ATTRS{idProduct}=="*", GROUP="dialout", MODE="0660"

      # Webcam permissions
      SUBSYSTEM=="video4linux", GROUP="video", MODE="0660"

      # Stream Deck devices (Elgato)
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="*", GROUP="plugdev", MODE="0666"
      SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="*", GROUP="plugdev", MODE="0666"
      # Stream Deck Plus specific rules
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="0084", GROUP="plugdev", MODE="0666"
      SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="0084", GROUP="plugdev", MODE="0666"

      # Vial keyboard configuration
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="plugdev", TAG+="uaccess", TAG+="udev-acl"
    '';

    # Syncthing - system service for user
    services.syncthing = {
      enable = true;
      user = userSettings.username;
      dataDir = "/home/${userSettings.username}/.config/syncthing";
      configDir = "/home/${userSettings.username}/.config/syncthing";
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
          "3D Print" = {
            path = "/home/${userSettings.username}/3D Print";
            devices = [ "unraid" ];
            id = "pxhhj-4rptz";
          };
        };
      };
    };

    # OBS Studio with plugins (system-level for proper integration)
    programs.obs-studio = {
      enable = true;
      # Temporarily disabled - v4l2loopback doesn't support kernel 6.18 yet
      enableVirtualCamera = false;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
        obs-composite-blur
      ];
    };

    # Enable the printer
    hardware.printers.TA-p-4025w.enable = true;

    # Steam gaming platform (system-level)
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    # TeamViewer remote desktop service
    services.teamviewer.enable = true;

    # Create /bin/python3 symlink for applications that expect it
    systemd.tmpfiles.rules = [
      "L+ /bin/python3 - - - - ${pkgs.python3}/bin/python3"
      "L+ /bin/python - - - - ${pkgs.python3}/bin/python3"
    ];
  };
}
