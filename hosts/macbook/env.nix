{ pkgs }:

{
  systemSettings = {
    hostname = "macbook";
    host = "macbook";
    timezone = "Europe/Sarajevo";
    locale = "en_US.UTF-8";
  };

  # Rec is recursive when you need more complex sets and nests
  #userSettings = rec {
  userSettings = {
    username = "stefanmatic";
    name = "Stefan Matic";
    email = "stefan.matic@openvpn.com"; # Work machine - OpenVPN identity
    theme = "dracula";
    term = "ghostty"; # Default terminal command;
    font = "Intel One Mono"; # Selected font
    fontPkg = pkgs.intel-one-mono; # Font package
    editor = "nano"; # Default editor;
  };
}
