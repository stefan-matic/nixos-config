{ pkgs, ... }:

{
  # Productivity and utility applications

  home.packages = with pkgs; [
    # Note-Taking & Knowledge Management
    unstable.affine

    # VPN Clients
    protonvpn-gui
    wgnord

    # Utilities
    wayfarer
    unstable.kiro

    # Terminal Enhancements
    fastfetch

    # Stream Deck & Hardware Control
    streamcontroller

    # Jumpin keyboard
    vial

    #Dygma keyboard
    unstable.bazecor
  ];
}
