{ pkgs, ... }:

{
  # Desktop infrastructure and Wayland/X11 support
  # Core tools needed for desktop environments and window managers

  environment.systemPackages = with pkgs; [
    # XDG/Desktop Integration
    desktop-file-utils # update-desktop-database for .desktop file indexing
    shared-mime-info # MIME type database

    # Wayland/Niri Infrastructure
    grim # Screenshot utility for Wayland
    slurp # Screen area selection for Wayland
    swappy # Screenshot annotation tool
    wf-recorder # Screen recording for Wayland
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

  # Create applications.menu symlink for KDE apps (Dolphin) to find applications
  # Dolphin looks for applications.menu but only plasma-applications.menu exists
  environment.etc."xdg/menus/applications.menu".source =
    "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";
}
