{ pkgs, ... }:

{
  # Creative and media production tools
  # Video editing, 3D modeling, image manipulation

  home.packages = with pkgs; [
    # Video Editing
    kdePackages.kdenlive
    davinci-resolve

    # Audio Effects & Production
    easyeffects

    # 3D Modeling & Printing
    prusa-slicer
    stable.openscad # broken on unstable: missing boost_system

    # Image Manipulation
    imagemagick

    # Image Viewers
    viu
    timg

    asciiquarium-transparent
  ];
}
