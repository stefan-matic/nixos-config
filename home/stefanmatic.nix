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

    # Additional package categories
    ../user/packages/development.nix
    ../user/packages/communication.nix
    ../user/packages/productivity.nix
    ../user/packages/creative.nix
    ../user/packages/gaming.nix

    # Application configurations
    ../user/app/swappy

    # Commented out services - uncomment if needed
    #../user/app/obs-studio.nix
    #./services/deej-serial-control.nix
    #./services/deej-new.nix
  ];

  _module.args = {
    inherit userSettings;
  };

  # User services
  services.kdeconnect = {
    enable = true;
    indicator = true;
  };

  services.mpris-proxy.enable = true;

  # Enable deej services if needed
  #services.deej-serial-control.enable = true;
  #services.deej-new.enable = true;

  # Cursor theme
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
}
