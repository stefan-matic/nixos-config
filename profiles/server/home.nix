{ config, pkgs, systemSettings, userSettings, ... }:

{
	imports = [
    ../default/home.nix
  ];

  home.packages =
    with pkgs; [
    ];
}


