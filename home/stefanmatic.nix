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
    ../user/wm/dms/dms.nix
    #../user/app/obs-studio.nix
    #./services/deej-serial-control.nix
    #./services/deej-new.nix
  ];

  _module.args = {
    inherit userSettings;
  };

  home.packages =
    with pkgs; [

      dbeaver-bin
      slack

      kubectl
      kubectx
      kubernetes-helm
      awscli2

      discord
      pre-commit
    ];

  services.kdeconnect = {
    enable = true;
    indicator = true;
  };

  # Enable deej-serial-control as a home-manager service
  # You can manually override this in host-specific configurations if needed
  #services.deej-serial-control.enable = true;

  # Enable the new deej service
  #services.deej-new.enable = true;

  home.pointerCursor =
    let
      getFrom = url: hash: name: {
          gtk.enable = true;
          x11.enable = true;
          name = name;
          size = 48;
          package =
            pkgs.runCommand "moveUp" {} ''
              mkdir -p $out/share/icons
              ln -s ${pkgs.fetchzip {
                url = url;
                hash = hash;
              }} $out/share/icons/${name}
          '';
        };
    in
      getFrom
        "https://github.com/ful1e5/fuchsia-cursor/releases/download/v2.0.1/Fuchsia.tar.xz"
        "sha256-TuhU8UFo0hbVShqsWy9rTKnMV8/WHqsxmpqWg1d9f84="
        "Fuchsia";

  services.mpris-proxy.enable = true;
}
