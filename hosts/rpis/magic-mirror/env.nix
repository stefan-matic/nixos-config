{ pkgs ? import <nixpkgs> {} }:

{
  # User settings
  userSettings = {
    username = "stefanmatic";
    name = "Stefan Matic";
    email = "stefan@matic.ba";
    theme = "stylix";
    terminal = "kitty";
    font = "JetBrains Mono";
    editor = "nvim";
  };

  # System settings
  systemSettings = {
    hostname = "magic-mirror";
    timezone = "Europe/Belgrade";
    locale = "en_US.UTF-8";
  };
}