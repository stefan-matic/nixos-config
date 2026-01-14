{ pkgs, ... }:

{
  # Gaming and entertainment

  home.packages = with pkgs; [
    # Steam launcher with DISPLAY fix for xwayland-satellite
    # Niri sets DISPLAY=:0 but xwayland-satellite connects on :1
    # Use 'steam-fix' to launch Steam with correct display
    steam-fix

    # Game Launchers
    lutris

    # Windows Compatibility
    wineWowPackages.stable
    winetricks

    # Vulkan Support (for gaming)
    vulkan-tools
    vulkan-loader
    vulkan-validation-layers
  ];
}
