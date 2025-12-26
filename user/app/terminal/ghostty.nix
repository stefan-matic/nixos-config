{ pkgs, lib, ... }:

{
  programs.ghostty = {
    enable = true;
    settings = {
      theme = "dracula";
    };
  };
}
