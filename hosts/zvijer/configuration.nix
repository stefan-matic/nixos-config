{ config, pkgs, inputs, ... }:

let
  env = import ./env.nix {inherit pkgs; };
  inherit (env) systemSettings userSettings;
in

{
  imports =
    [
      ../_common.nix
      ./hardware-configuration.nix
    ];

  _module.args = {
    inherit systemSettings userSettings;
  };
}
