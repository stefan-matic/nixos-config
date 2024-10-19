{ pkgs }:

{
  systemSettings = {
    system = "x86_64-linux";
    hostname = "RWTF";
    profile = "starlabs";
    timezone = "Europe/Sarajevo";
    locale = "en_US.UTF-8";
  };

  # Rec is recursive when you need more complex sets and nests
  #userSettings = rec {
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
}