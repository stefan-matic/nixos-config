{ config, pkgs, lib, ... }:

let
  viberWrapper = pkgs.writeScriptBin "viber-wrapped" ''
    #!${pkgs.bash}/bin/bash
    export HOME="${config.home.homeDirectory}"
    cd "$HOME"
    exec ${pkgs.viber}/opt/viber/Viber "$@"
  '';
in
{
  home.packages = [ viberWrapper pkgs.viber ];

  # Create required directories
  home.file.".local/share/Viber".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.local/share/Viber";
  home.file.".config/Viber".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/Viber";

  # Create a custom desktop entry that uses our wrapper
  xdg.desktopEntries.viber = {
    name = "Viber";
    exec = "viber-wrapped %U";
    icon = "${pkgs.viber}/share/icons/hicolor/128x128/apps/viber.png";
    terminal = false;
    categories = [ "Network" "InstantMessaging" ];
    mimeType = [ "x-scheme-handler/viber" ];
  };

  # Ensure the directories exist
  systemd.user.tmpfiles.rules = [
    "d ${config.home.homeDirectory}/.local/share/Viber 0755 ${config.home.username} users"
    "d ${config.home.homeDirectory}/.config/Viber 0755 ${config.home.username} users"
  ];
}
