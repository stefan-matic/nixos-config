{ pkgs, ... }:

{
  # Gaming and entertainment

  home.packages = with pkgs; [
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
