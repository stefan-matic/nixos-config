{ config, pkgs, systemSettings, userSettings, ... }:

{
	imports = [
    ../default/home.nix
    ../../user/app/obs-studio.nix
  ];

  home.packages =
    with pkgs; [
      #viber
      prusa-slicer

      dbeaver-bin
      slack
      yubioath-flutter
    ];
}


