{ config, pkgs, inputs, outputs, lib, ... }:

let
  userSettings = {
    username = "stefanmatic";
    name = "Stefan Matic";
    email = "stefanmatic94@gmail.com";
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
    #../user/app/obs-studio.nix
    ./services/deej-serial-control.nix
  ];

  _module.args = {
    inherit userSettings;
  };

  home.packages =
    with pkgs; [
      prusa-slicer

      dbeaver-bin
      slack
      #yubioath-flutter

      terraform
      opentofu
      kubectl
      awscli2
    ];

  services.kdeconnect = {
    enable = true;
    indicator = true;
  };

  # Enable deej-serial-control as a home-manager service
  # You can manually override this in host-specific configurations if needed
  services.deej-serial-control.enable = true;
}
