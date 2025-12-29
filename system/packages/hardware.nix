{ pkgs, ... }:

{
  # Hardware tools and control utilities
  # Tools that interact with hardware or require system-level access

  environment.systemPackages = with pkgs; [
    # Hardware Information
    lm_sensors       # Temperature sensors
    pciutils         # lspci
    usbutils         # lsusb

    # Hardware Control
    brightnessctl    # Backlight control
    pavucontrol      # Audio control GUI
    pamixer          # Audio control CLI

    # Disk Management (system-wide)
    gparted
    gnome-disk-utility
  ];
}
