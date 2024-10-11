{ config, pkgs, systemSettings, userSettings, ... }:

{
	imports = [
    ../main/home.nix
  ];

  home.packages =
    with pkgs; [
    ];
}


