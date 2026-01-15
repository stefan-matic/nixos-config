# SD Card Image Building Configuration
# This configuration can be imported by Pi configurations to enable SD image building
# Based on the Reddit examples and nixos-pi-zero-2 repository

{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  # Import the official SD image modules
  imports = [
    "${modulesPath}/installer/sd-card/sd-image.nix"
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
  ];

  # Disable modules that aren't needed for SD images
  disabledModules = [
    "profiles/all-hardware.nix"
    "profiles/base.nix"
  ];

  # SD Image configuration options
  options.sdImage = with lib; {
    extraFirmwareConfig = mkOption {
      type = types.attrs;
      default = { };
      description = lib.mdDoc ''
        Extra configuration to be added to config.txt firmware file.
        This allows customization of boot parameters, GPU memory split, etc.
      '';
    };
  };

  config = {
    # SD Image generation settings
    sdImage = {
      # Image naming and compression
      imageName = lib.mkDefault "${config.networking.hostName or "nixos"}-sd-image.img";
      compressImage = lib.mkDefault false; # Skip compression for faster builds

      # Firmware configuration injection
      populateFirmwareCommands =
        lib.mkIf ((lib.length (lib.attrValues config.sdImage.extraFirmwareConfig)) > 0)
          (
            let
              # Convert attribute set to config.txt format
              keyValueMap = name: value: "${name}=${toString value}";
              keyValueList = lib.mapAttrsToList keyValueMap config.sdImage.extraFirmwareConfig;
              extraFirmwareConfigString = lib.concatStringsSep "\n" keyValueList;
            in
            lib.mkAfter ''
              # Add extra firmware configuration to config.txt
              config=firmware/config.txt
              chmod u+w $config
              echo "" >> $config
              echo "# Extra configuration from NixOS" >> $config
              echo "${extraFirmwareConfigString}" >> $config
              chmod u-w $config
            ''
          );
    };

    # Optimize the image for first boot
    system.activationScripts.expandFileSystem = lib.mkAfter ''
      # Expand root filesystem on first boot
      if [ ! -f /etc/expanded-root ]; then
        ${pkgs.e2fsprogs}/bin/resize2fs /dev/mmcblk0p2 || true
        touch /etc/expanded-root
      fi
    '';

    # Network configuration for initial setup
    networking = {
      # Enable predictable interface names
      usePredictableInterfaceNames = lib.mkDefault false;

      # DHCP on wlan0 for initial setup
      interfaces.wlan0.useDHCP = lib.mkDefault true;

      # Wireless configuration placeholder
      wireless = {
        enable = lib.mkDefault true;
        interfaces = [ "wlan0" ];
        # Networks should be configured in specific host configurations
        networks = lib.mkDefault { };
      };
    };

    # Services for initial setup and remote access
    services = {
      # Enable SSH for initial setup
      openssh = {
        enable = lib.mkForce true;
        settings = {
          PermitRootLogin = "no";
          KbdInteractiveAuthentication = false;
          # Allow password authentication on first boot if no keys are configured
          PasswordAuthentication = lib.mkIf (
            config.users.users ? root && config.users.users.root.openssh.authorizedKeys.keys == [ ]
          ) (lib.mkOverride 999 true);
        };
      };

      # Enable Avahi for easy discovery
      avahi = {
        enable = lib.mkDefault true;
        nssmdns4 = true;
        openFirewall = true;
        publish = {
          enable = true;
          addresses = true;
          domain = true;
          hinfo = true;
          userServices = true;
          workstation = true;
        };
      };

      # Time synchronization
      timesyncd.enable = true;
    };

    # System optimization for SD card images
    boot = {
      # Clean tmp on boot to save space
      tmp.cleanOnBoot = true;

      # Kernel parameters for SD card optimization
      kernelParams = [
        # Reduce kernel log spam
        "quiet"
        "splash"

        # Optimize for SD card
        "rootfstype=ext4"
        "rootwait"
      ];
    };

    # Environment setup
    environment.systemPackages = with pkgs; [
      # Basic tools for initial setup
      wget
      curl
      git
      vim
      htop
      tmux

      # Network tools
      iw
      wireless-tools

      # System tools
      file
      lsof
      psmisc
    ];

    # User setup - should be overridden in specific configurations
    users = {
      # Disable mutable users for reproducibility
      mutableUsers = lib.mkDefault false;

      # Default root with disabled login
      users.root = {
        # Disable root login by default
        hashedPassword = lib.mkDefault "!";
        openssh.authorizedKeys.keys = lib.mkDefault [ ];
      };
    };

    # Security hardening for SD images
    security = {
      # Disable sudo password for emergency access
      sudo.wheelNeedsPassword = lib.mkDefault false;

      # Lock down the system
      lockKernelModules = lib.mkDefault false; # Allow hardware detection
    };

    # System state version
    system.stateVersion = lib.mkDefault "25.05";
  };
}
