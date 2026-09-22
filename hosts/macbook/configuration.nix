# Apple Silicon MacBook Pro, managed by nix-darwin.
#
# Same shape as the NixOS hosts (hosts/t14/configuration.nix): env.nix supplies
# the settings, _common carries the policy, packages.nix the host system
# packages. The differences are structural rather than stylistic -- there is no
# hardware-configuration.nix (macOS owns the disk and the bootloader), and the
# GUI applications come from homebrew.nix instead of home.packages.
{
  pkgs,
  lib,
  ...
}:

let
  env = import ./env.nix { inherit pkgs; };
  inherit (env) systemSettings userSettings;
in

{
  imports = [
    ../_common/darwin.nix
    ./packages.nix # macbook-specific system packages
    ./homebrew.nix # GUI applications as casks
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

    # macOS keeps three separate names: the Finder/AirDrop name, the shell
    # hostname, and the Bonjour name. NixOS only has the one.
    networking = {
      computerName = systemSettings.hostname;
      hostName = systemSettings.hostname;
      localHostName = systemSettings.hostname;
    };

    # Home-manager user configuration
    home-manager.extraSpecialArgs.terminalFontSize = 13; # Retina panel
    home-manager.users.${userSettings.username} = {
      imports = [ ../../home/darwin.nix ];
    };
  };
}
