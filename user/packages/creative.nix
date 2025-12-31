{ pkgs, ... }:

{
  # Creative and media production tools
  # Video editing, 3D modeling, image manipulation

  home.packages = with pkgs; [
    # Video Editing
    kdePackages.kdenlive

    # Audio Effects & Production
    easyeffects

    # 3D Modeling & Printing
    prusa-slicer
    openscad

    # Image Manipulation
    imagemagick

    # Image Viewers
    viu
    timg
  ];
}
