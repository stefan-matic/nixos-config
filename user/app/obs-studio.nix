{ config, pkgs, ... }:

{
  programs.obs-studio = {
    enable = true;
    #enableVirtualCamera = true;
  };

  #programs.obs-studio.enableVirtualCamera = true;

  home.packages = [
  ];

  #Set up default path for videos
}
