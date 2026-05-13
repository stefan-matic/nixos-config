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

  # Import unstable nixpkgs for DMS
  unstablePkgs = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };
in

{
  imports = [
    ./hardware-configuration.nix
    ../_common/client.nix
    ./packages.nix # ZVIJER-specific system packages
    ../../system/devices/TA-p-4025w
    # Import DMS NixOS module
    inputs.dms.nixosModules.dank-material-shell
    # NordVPN module (from different-error's nixpkgs fork).
    # Wrapped to strip `meta.doc`, which would otherwise register the
    # identifier `module-services-nordvpn` and break the NixOS manual build
    # against main nixpkgs (missing redirect entry).
    (
      {
        config,
        lib,
        pkgs,
        options,
        ...
      }@args:
      builtins.removeAttrs
        (import "${inputs.nixpkgs-nordvpn}/nixos/modules/services/networking/nordvpn.nix" args)
        [ "meta" ]
    )
    # YubiKey PAM authentication (touch to sudo)
    ../../system/security/yubikey.nix
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
    # Cap build parallelism to avoid OOM on big C++ builds (chromium/electron/llvm).
    # max-jobs * cores must stay well under nproc=32; cc1plus can use 1-4 GB each.
    nix.settings.max-jobs = 4;
    nix.settings.cores = 8;

    # Pass settings to child modules
    _module.args = {
      inherit systemSettings userSettings;
    };

    # Home-manager user configuration
    home-manager.extraSpecialArgs.terminalFontSize = 11; # Larger font for 57" ultrawide
    home-manager.users.${userSettings.username} = {
      imports = [
        ../../home/stefanmatic.nix
        ../../user/wm/niri/ZVIJER.nix
        ../../user/wm/dms/dsearch.nix
        ../../user/app/input-remapper.nix
      ];
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
        theme = pkgs.sleek-grub-theme.override { withStyle = "dark"; };
        gfxmodeEfi = "1920x1080,auto";
        gfxpayloadEfi = "keep";
        extraEntries = ''
          menuentry "Windows 11" {
            insmod part_gpt
            insmod fat
            insmod chain
            # Search for EFI partition and chainload Windows bootloader
            search --no-floppy --fs-uuid --set=root FDAE-C0AC
            chainloader /EFI/Microsoft/Boot/bootmgfw.efi
          }
        '';
      };
      systemd-boot.enable = lib.mkForce false;
      timeout = 5;
    };

    # System packages for dual-boot and filesystems
    environment.systemPackages = with pkgs; [
      ntfs3g # NTFS filesystem support for Windows partition
    ];

    # DankMaterialShell - system-level installation
    programs.dank-material-shell = {
      enable = true;

      # Systemd service disabled - DMS is spawned by Niri instead
      systemd = {
        enable = false;
      };

      # Core features
      # enableSystemMonitoring requires dgop package which is not available
      enableSystemMonitoring = false;
      enableVPN = true; # VPN management widget
      enableDynamicTheming = true; # Wallpaper-based theming (matugen)
      enableAudioWavelength = true; # Audio visualizer (cava)
      enableCalendarEvents = false; # Calendar integration (khal) - disabled: khal broken upstream
      # Note: enableClipboard, enableColorPicker, enableBrightnessControl, enableSystemSound
      # are now built-in to DMS and no longer need to be specified
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

    # Enable NordVPN service (package comes from the fork overlay below)
    services.nordvpn.enable = true;

    # Provide `pkgs.nordvpn` from different-error's nixpkgs fork so the
    # imported module picks it up via mkPackageOption.
    nixpkgs.overlays = [
      (_final: _prev: {
        nordvpn =
          (import inputs.nixpkgs-nordvpn {
            inherit (pkgs.stdenv.hostPlatform) system;
            config.allowUnfree = true;
          }).nordvpn;
      })
    ];

    # Enable OpenRazer hardware daemon
    hardware.openrazer = {
      enable = true;
      users = [ userSettings.username ];
    };

    # Input Remapper - autostart without password
    services.input-remapper = {
      enable = true;
      enableUdevRules = true;
    };

    # Allow input-remapper GUI to run without sudo password
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id === "inputremapper" && subject.isInGroup("users")) {
          return polkit.Result.YES;
        }
      });
    '';

    # Temporarily disabled - OpenRazer doesn't support kernel 6.18 yet
    # boot.extraModulePackages = with config.boot.kernelPackages; [
    #   openrazer
    # ];

    # Add user to required groups
    users.users.${userSettings.username} = {
      extraGroups = [
        "dialout"
        "uucp"
        "plugdev"
        "video"
        "openrazer"
      ];
    };

    # Ensure plugdev group exists
    users.groups.plugdev = { };

    # Add udev rules for Arduino, webcam, Stream Deck, and Vial keyboard
    services.udev.extraRules = ''
      SUBSYSTEM=="tty", ATTRS{idVendor}=="2341", ATTRS{idProduct}=="*", GROUP="dialout", MODE="0660"
      SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="*", GROUP="dialout", MODE="0660"
      SUBSYSTEM=="tty", ATTRS{idVendor}=="2a03", ATTRS{idProduct}=="*", GROUP="dialout", MODE="0660"

      # Webcam permissions
      SUBSYSTEM=="video4linux", GROUP="video", MODE="0660"

      # Stream Deck devices (Elgato) - OpenDeck udev rules
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="0060", MODE="0660", TAG+="uaccess"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="0063", MODE="0660", TAG+="uaccess"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="006c", MODE="0660", TAG+="uaccess"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="006d", MODE="0660", TAG+="uaccess"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="0080", MODE="0660", TAG+="uaccess"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="0084", MODE="0660", TAG+="uaccess"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="0086", MODE="0660", TAG+="uaccess"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="008f", MODE="0660", TAG+="uaccess"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="0090", MODE="0660", TAG+="uaccess"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="00b3", MODE="0660", TAG+="uaccess"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="009a", MODE="0660", TAG+="uaccess"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="00a5", MODE="0660", TAG+="uaccess"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="00b8", MODE="0660", TAG+="uaccess"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="00b9", MODE="0660", TAG+="uaccess"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="00ba", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="0060", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="0063", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="006c", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="006d", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="0080", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="0084", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="0086", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="008f", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="0090", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="00b3", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="009a", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="00a5", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="00b8", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="00b9", MODE="0660", TAG+="uaccess"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="00ba", MODE="0660", TAG+="uaccess"

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
          "Claude Code" = {
            path = "/home/${userSettings.username}/.claude";
            devices = [ "unraid" ];
            id = "crwsq-yjurj";
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

    # Ollama - local LLM inference with ROCm acceleration
    services.ollama = {
      enable = true;
      package = pkgs.ollama-rocm;
    };

    # AMD GPU (RX 6900 XT)
    services.xserver.videoDrivers = [ "amdgpu" ];

    boot.kernelParams = [
      # IOMMU for GPU passthrough (RX 7600 → Windows VM)
      "amd_iommu=on"
      "iommu=pt"
      # Bind RX 7600 (GPU + Audio) to vfio-pci for VM passthrough
      "vfio-pci.ids=1002:7480,1002:ab30"
    ];

    # OpenRGB - i2c access for RGB control (motherboard, RAM, cooler)
    hardware.i2c.enable = true;
    services.udev.packages = [ pkgs.openrgb-with-all-plugins ];

    # Enable the printer
    hardware.printers.TA-p-4025w.enable = true;

    # k3d Kubernetes cluster - allow remote access from other machines
    networking.firewall = {
      allowedTCPPorts = [
        37441 # k3d API server
      ];
      allowedTCPPortRanges = [
        {
          from = 30000;
          to = 32767;
        } # Kubernetes NodePort range
      ];
    };

    # Steam gaming platform (system-level)
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      # Enable gamescope (available if needed for specific games)
      gamescopeSession.enable = false;
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
