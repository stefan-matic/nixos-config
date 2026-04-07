{ pkgs, ... }:

{
  # Productivity and utility applications

  home.packages = with pkgs; [
    # Note-Taking & Knowledge Management
    unstable.affine

    # VPN Clients
    proton-vpn
    wgnord

    # Utilities
    wayfarer
    unstable.kiro

    # Text Expander
    espanso-wayland

    # Terminal Enhancements
    fastfetch

    # Stream Deck & Hardware Control
    opendeck

    # Jumpin keyboard
    vial

    #Dygma keyboard
    unstable.bazecor
  ];
}
