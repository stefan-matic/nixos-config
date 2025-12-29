{ config, ... }:

{
  # Swappy - Wayland screenshot annotation tool
  # https://github.com/jtheoof/swappy

  home.file.".config/swappy/config".text = ''
    [Default]
    # Save screenshots to this directory
    save_dir=${config.home.homeDirectory}/Pictures/Screenshots

    # Save filename format (date-time based)
    save_filename_format=screenshot-%Y%m%d-%H%M%S.png

    # Show screenshot panel at launch
    show_panel=true

    # Line size for drawing
    line_size=5

    # Text size
    text_size=20

    # Text font
    text_font=sans-serif

    # Paint mode (draw|arrow|rectangle|ellipse|text|blur)
    paint_mode=draw

    # Early exit (don't show window, just save)
    early_exit=false

    # Fill shapes by default
    fill_shape=false
  '';

  # Create Screenshots directory
  home.file."Pictures/Screenshots/.keep".text = "";
}
