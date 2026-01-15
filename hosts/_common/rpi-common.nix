# Unified Raspberry Pi configuration for Pi 4 and Pi Zero 2W
# Usage:
#   For Pi 4: import with { piModel = "4"; }
#   For Pi Zero 2W: import with { piModel = "zero2w"; }

{
  lib,
  inputs,
  outputs,
  config,
  pkgs,
  userSettings,
  systemSettings,
  piModel ? "4", # Default to Pi 4, can be "4" or "zero2w"
  ...
}:

let
  isPi4 = piModel == "4";
  isPiZero2W = piModel == "zero2w";

  # Hardware-specific configurations
  hwConfig =
    if isPi4 then
      {
        # Pi 4 configuration
        kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
        nixosHardwareModule = inputs.nixos-hardware.nixosModules.raspberry-pi-4;
        gpuMemSplit = "256M"; # More memory for Pi 4
        firmwareConfig = { };
        enableFkms3d = true;
        enableDtmerge = true;
      }
    else
      {
        # Pi Zero 2W configuration
        kernelPackages = pkgs.linuxPackages_rpi02w;
        nixosHardwareModule = null; # No nixos-hardware module for Zero 2W yet
        gpuMemSplit = "16M"; # Minimal GPU memory for Zero 2W
        firmwareConfig = {
          # Zero 2W specific firmware config
          start_x = 0; # Disable camera
          gpu_mem = 16; # Minimal GPU memory
          hdmi_group = 2; # DMT mode
          hdmi_mode = 8; # 800x600 60Hz
        };
        enableFkms3d = false;
        enableDtmerge = false;
      };

  # Package allowMissing overlay for Zero 2W
  packageOverlay = lib.optionals isPiZero2W [
    (final: super: {
      makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];

in
{
  imports = [
    ./default.nix
  ]
  ++ lib.optionals (hwConfig.nixosHardwareModule != null) [ hwConfig.nixosHardwareModule ];

  # Apply package overlay for Zero 2W
  nixpkgs.overlays = packageOverlay;

  # Platform configuration
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  # Pi 4 specific hardware settings
  hardware.raspberry-pi."4" = lib.mkIf isPi4 {
    # Enable firmware kernel mode setting for 3D acceleration
    # Note: This may be broken in some versions, see nixos-hardware issue #631
    fkms-3d.enable = hwConfig.enableFkms3d;

    # Apply device tree overlays using dtmerge
    apply-overlays-dtmerge.enable = hwConfig.enableDtmerge;
  };

  # Pi Zero 2W device tree configuration
  hardware.deviceTree = lib.mkIf isPiZero2W {
    enable = true;
    kernelPackage = pkgs.linuxKernel.packages.linux_rpi3.kernel;
    filter = "*2837*";

    # Custom overlays can be added here
    overlays = [
      # Example I2C overlay (uncomment if needed)
      # {
      #   name = "enable-i2c";
      #   dtsFile = ./dts/i2c.dts;
      # }
    ];
  };

  # Boot configuration
  boot = {
    kernelPackages = hwConfig.kernelPackages;
    initrd.availableKernelModules = [
      "xhci_pci"
      "usbhid"
      "usb_storage"
    ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };

    # GPU memory allocation
    kernelParams = lib.optionals isPi4 [
      "cma=${hwConfig.gpuMemSplit}" # GPU memory split
    ];

    # Disable software RAID for Zero 2W to avoid warnings
    swraid.enable = lib.mkIf isPiZero2W (lib.mkForce false);
  };

  # SD Image configuration (when building images)
  sdImage = lib.mkIf isPiZero2W {
    compressImage = lib.mkDefault false; # Skip compression for faster builds
    imageName = "zero2w.img";
    extraFirmwareConfig = hwConfig.firmwareConfig;
  };

  # File systems - adjust as needed for your SD card setup
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  # Network configuration
  networking = {
    useDHCP = lib.mkDefault true;
    wireless = {
      enable = lib.mkDefault true; # Enable WiFi support
      interfaces = lib.mkDefault [ "wlan0" ];
    };
  };

  # Enable SSH for remote access
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
    allowSFTP = true;
  };

  # SSH keys for remote access
  users.users.${userSettings.username}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDJ2jVUL/jANIzKv14MfJN6bNQzYD41BJssTZiDL34sk stefan@matic.ba"
  ];

  # Basic system packages for Raspberry Pi
  environment.systemPackages =
    with pkgs;
    [
      git
      htop
      tmux
      vim
      wget
      curl
    ]
    ++ lib.optionals isPi4 [
      # Pi 4 specific packages
      libraspberrypi
      raspberrypi-eeprom
    ]
    ++ lib.optionals isPiZero2W [
      # Zero 2W specific packages
      raspberrypiWirelessFirmware
      i2c-tools # Useful for GPIO projects
    ];

  # Enable hardware features
  hardware = {
    enableRedistributableFirmware = if isPiZero2W then lib.mkForce false else true;
    firmware = lib.optionals isPiZero2W [ pkgs.raspberrypiWirelessFirmware ];

    # Enable I2C, SPI, GPIO if needed
    i2c.enable = lib.mkDefault isPiZero2W; # Default enabled for Zero 2W
    spi.enable = lib.mkDefault false;
  };

  # Power management for Raspberry Pi
  powerManagement.cpuFreqGovernor = lib.mkDefault (if isPiZero2W then "powersave" else "ondemand");

  # Disable services that might not be needed on Pi
  services = {
    # Disable X11 by default (can be overridden in specific hosts)
    xserver.enable = lib.mkDefault false;

    # Enable systemd watchdog and time sync
    systemd-timesyncd.enable = true;
    timesyncd.enable = lib.mkDefault isPiZero2W;

    # Enable Avahi for Zero 2W for easier discovery
    avahi = lib.mkIf isPiZero2W {
      enable = lib.mkDefault true;
      nssmdns4 = true;
      openFirewall = true;
      publish = {
        enable = true;
        addresses = true;
        domain = true;
        workstation = true;
      };
    };
  };

  # Memory and swap configuration
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = if isPiZero2W then 50 else 25; # More aggressive swap for Zero 2W
  };

  # Reduce journal size to save SD card space
  services.journald.extraConfig = ''
    SystemMaxUse=${if isPiZero2W then "50M" else "100M"}
    RuntimeMaxUse=${if isPiZero2W then "25M" else "50M"}
  '';

  # Optimize for SD card longevity
  boot.tmp.useTmpfs = true;

  # Mount /var/log in tmpfs to reduce SD card writes
  fileSystems."/var/log" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [
      "rw"
      "nodev"
      "nosuid"
      "size=${if isPiZero2W then "25M" else "50M"}"
    ];
  };

  # Security configuration
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # Trust wheel users for Nix operations
  nix.settings.trusted-users = [ "@wheel" ];
}
