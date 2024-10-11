{ config, pkgs, ... }:

{
  programs.obs-studio = {
    enable = true;
  };
  
  home.packages = [
    pkgs.obs-studio-plugins.obs-hyperion
  ];

  #Set up default path for videos
}