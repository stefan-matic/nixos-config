{ pkgs, ... }:

{
  # Desktop infrastructure and Wayland/X11 support
  # Core tools needed for desktop environments and window managers

  environment.systemPackages = with pkgs; [
    # Wayland/Niri Infrastructure
    grim # Screenshot utility for Wayland
    slurp # Screen area selection for Wayland
    swappy # Screenshot annotation tool
    wl-clipboard # Wayland clipboard utilities
    cliphist # Clipboard history manager
    xwayland-satellite # XWayland support for X11 apps

    # File Manager & GVFS
    nautilus # GNOME file manager
    gvfs # Virtual filesystem (USB, network shares)

    # KDE Applications (system-wide utilities)
    kdePackages.kcalc
    kdePackages.kate
    kdePackages.kdialog

    # Input Tools
    xdotool
    kdotool
    ydotool

    # Mesa (OpenGL demos/testing)
    mesa-demos
  ];

  # Enable GVFS for file manager integration
  services.gvfs.enable = true;
}
