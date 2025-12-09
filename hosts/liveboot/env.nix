{ pkgs }:

{
  systemSettings = {
    hostname = "stefan-nix-live";
    host = "stefan-nix-live";
    timezone = "Europe/Sarajevo";
    locale = "en_US.UTF-8";
  };

  userSettings = {
    username = "stefan";
    name = "stefan";
    email = "stefan@matic.ba";
    theme = "dracula";
    term = "alacritty";
    font = "Intel One Mono";
    fontPkg = pkgs.intel-one-mono;
    editor = "nano";
  };
}
