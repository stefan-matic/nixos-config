# Example DMS Greeter Configuration
# Copy this snippet to your host configuration to enable DMS greeter
#
# Location: hosts/{hostname}/configuration.nix
#
# This example shows how to enable DMS greeter with Niri compositor
# and automatic theme synchronization.

{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    # Add greeter module import
    ../../user/wm/dms/greeter.nix
  ];

  # DMS Greeter Configuration
  services.dms-greeter = {
    # Enable the greeter
    enable = true;

    # Choose compositor: "niri", "hyprland", "sway", or "mangowc"
    compositor = "niri";

    # Use custom Niri configuration for greeter
    # This provides a minimal, clean layout suitable for login screen
    niriConfig = builtins.readFile ../../user/wm/dms/greeter-niri.kdl;

    # Alternatively, for Hyprland:
    # compositor = "hyprland";
    # hyprlandConfig = ''
    #   monitor=,preferred,auto,1
    #   # Your Hyprland config here
    # '';

    # Enable automatic theme synchronization
    # This syncs wallpapers and themes from user configs to greeter
    enableThemeSync = true;

    # Users whose themes should be synced to greeter
    themeSyncUsers = [ "stefanmatic" ];
  };

  # Note: The greeter will:
  # - Replace SDDM/GDM/LightDM if previously configured
  # - Use greetd as the display manager
  # - Launch with the chosen compositor (Niri by default)
  # - Remember last selected session and user
  # - Match the visual style of your DMS lock screen

  # After enabling, rebuild with:
  # sudo nixos-rebuild switch --flake ~/.dotfiles#ZVIJER
}
