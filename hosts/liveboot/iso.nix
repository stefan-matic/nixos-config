{ config, pkgs, lib, inputs, modulesPath, ... }:

let
  env = import ./env.nix { inherit pkgs; };
  inherit (env) systemSettings userSettings;
in

{
  imports = [
    # Base ISO configuration with Plasma 6 graphical environment
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"

    # Import all common configurations
    ../_common/default.nix
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

    # Set the system platform
    nixpkgs.hostPlatform = "x86_64-linux";

    # Override hostname for live boot (using systemSettings from env.nix)
    networking.hostName = lib.mkForce systemSettings.hostname;

    # ISO-specific settings
    image.fileName = "${systemSettings.hostname}-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.iso";

    isoImage = {
      makeEfiBootable = true;
      makeUsbBootable = true;
      # Compress the squashfs more (takes longer but smaller ISO)
      squashfsCompression = "zstd -Xcompression-level 15";
    };

    # Enable autologin for the live user (using userSettings from env.nix)
    services.displayManager.autoLogin = {
      enable = true;
      user = lib.mkForce userSettings.username;
    };

    # Additional useful packages for live environment
    environment.systemPackages = with pkgs; [
      # Partitioning and disk tools
      gparted
      ntfs3g
      exfat

      # System utilities
      vim
      nano
      git
      wget
      curl
      htop

      # Network tools
      firefox
      networkmanagerapplet

      # File manager
      kdePackages.dolphin
      kdePackages.konsole
      kdePackages.kate
    ];
  };
}
