{
  config,
  ...
}:
{
  services.hyprpaper.enable = true;

  services.hyprpaper.settings = {
    preload = ["${config.stylix.image}"];
    wallpaper = [",${config.stylix.image}"];
  };
}