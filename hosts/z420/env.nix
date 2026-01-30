{ pkgs }:

{
  systemSettings = {
    system = "x86_64-linux";
    hostname = "z420";
    host = "Z420";
    timezone = "Europe/Sarajevo";
    locale = "en_US.UTF-8";
    # Locale settings: English with dd-mm-yyyy date format
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_GB.UTF-8"; # Use British English for dd-mm-yyyy format
    };
  };

  # Rec is recursive when you need more complex sets and nests
  #userSettings = rec {
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
}
