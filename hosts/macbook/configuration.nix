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
    ../_common/darwin.nix
    ./packages.nix # macbook-specific system packages
    ./homebrew.nix # GUI applications as casks
    ./skhd.nix # application-launch hotkeys (paneru cannot spawn processes)
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

    networking = {
      hostName = systemSettings.hostname;
      computerName = systemSettings.hostname;
      localHostName = systemSettings.hostname;
    };

    # Home-manager user configuration.
    #
    # Paneru is wired in here rather than as a darwin module: it has to run
    # inside the user's Aqua session to hold Accessibility permission, so a
    # per-user launchd agent is the correct level. This also keeps
    # user/wm/paneru/ a home-manager module set, mirroring user/wm/niri/.
    home-manager.extraSpecialArgs.terminalFontSize = 13; # Retina 14" display
    home-manager.users.${userSettings.username} = {
      imports = [
        inputs.paneru.homeModules.paneru
        ../../home/darwin.nix
      ];
    };
  };
}
