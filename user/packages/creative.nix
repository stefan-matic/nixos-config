{ pkgs, ... }:

{
  # Creative and media production tools
  # Video editing, 3D modeling, image manipulation

  home.packages = with pkgs; [
    # Video Editing
    kdePackages.kdenlive

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
