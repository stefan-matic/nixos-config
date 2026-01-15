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
in

{
  imports = [
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

    # Minimal boot configuration for live environment
    boot.loader = {
      systemd-boot.enable = lib.mkDefault true;
      efi.canTouchEfiVariables = lib.mkDefault true;
    };

    # Add some useful packages for a live environment
    environment.systemPackages = with pkgs; [
      # System tools
      gparted
      ntfs3g
      exfat

      # Editors
      vim
      nano

      # Network tools
      firefox
      networkmanagerapplet
    ];
  };
}
