{
  pkgs,
  lib,
  config,
  ...
}:

let
  env = import ./env.nix { inherit pkgs; };
  inherit (env) systemSettings userSettings;
in

{
  imports = [
    ./hardware-configuration.nix
    ../_common/server.nix
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
    _module.args = {
      inherit systemSettings userSettings;
    };

    # Boot configuration
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Firewall
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # SSH
        80
        443
      ];
    };

    # Add host-specific services below
  };
}
