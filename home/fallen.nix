{ config, pkgs, ... }:

let
  userSettings = {
    username = "fallen";
    name = "Fallen";
    email = "lordmata94@gmail.com";
    theme = "dracula";
    term = "alacritty"; # Default terminal command;
    font = "Intel One Mono"; # Selected font
    fontPkg = pkgs.intel-one-mono; # Font package
    editor = "nano"; # Default editor;
  };
in

{
	imports = [
    ./_common.nix
    ../user/app/obs-studio.nix
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


