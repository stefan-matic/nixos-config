{ pkgs, ... }:

{
  # Creative and media production tools
  # Video editing, 3D modeling, image manipulation

  home.packages = with pkgs; [
    # Video Editing
    kdePackages.kdenlive
    # davinci-resolve: disabled 2026-09-11 — Blackmagic silently re-uploaded the
    # 21.1 zip, so the nixpkgs fixed-output hash no longer matches:
    #   specified sha256-bQ4Yag4xfIF9Fs0UVKaYFhObMsAof5n+Sy4osw35a9g=
    #   got       sha256-+3SB32EHpH9/0hM3h8CrO6f7V4ZAmxUFh3P8m6QDeO0=
    # Re-enable once nixpkgs updates the hash upstream (nixpkgs#561607 bumped 21.1).
    # davinci-resolve

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
