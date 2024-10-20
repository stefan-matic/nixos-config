{ config, pkgs, inputs, ... }:

let
  env = import ./env.nix {inherit pkgs; };
  inherit (env) systemSettings userSettings;
in

{
  imports =
    [
      ./hardware-configuration.nix
      ../_common.nix
    ];

  _module.args = {
    inherit systemSettings userSettings;
  };

  services.syncthing = {
    enable = true;
    settings = {
      gui = {
        theme = "dark";
        user = userSettings.username;
        password = "$2a$12$YQaEAuhPAMDSXfAATiYQZOA049upLP7oNEi3U8FAqkP6vaNH6mnlW";
      };
      devices = {
        unraid = {
          id = "2T25XJC-SXWEDMA-DF4P57K-55AQCXQ-2MYHHLJ-IXF24KU-HNMUWRN-4W2R3AY";
        };
      };
    };
  }; 
}
