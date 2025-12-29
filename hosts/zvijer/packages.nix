{ pkgs, ... }:

let
  customPkgs = import ../../pkgs { inherit pkgs; };
in

{
  # ZVIJER-specific system packages
  # Hardware-specific tools and system utilities unique to this host

  environment.systemPackages = with pkgs; [
    # Custom packages
    customPkgs.select-browser
    kdePackages.kdialog

    # Razer hardware support (system-wide daemon needed)
    openrazer-daemon
    razergenie
    input-remapper

    # Terminal (if needed system-wide, otherwise move to home-manager)
    ghostty

    # System utilities for this specific setup
    fastfetch
  ];
}
