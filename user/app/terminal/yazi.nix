{ pkgs, lib, ... }:

{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
  };

  # Make sure we have all dependencies for media previews
  home.packages = with pkgs; [
    ffmpeg # For video/GIF thumbnails and previews
    mpv # For video playback in terminal
    f3d # 3D model viewer for STL, 3MF, OBJ, STEP files
    # Already installed in sh.nix:
    # ffmpegthumbnailer - video thumbnails
    # ueberzugpp - image display protocol
    # poppler-utils - PDF preview
    # imagemagick - image processing
    # chafa - image viewer
  ];

  # Write yazi.toml configuration
  xdg.configFile."yazi/yazi.toml".text = ''
    [mgr]
    # Give more space to preview pane (50%)
    ratio = [1, 3, 4]
    # Default to alphabetical sorting (use 's' keybindings to change per directory)
    sort_by = "alphabetical"
    sort_reverse = false
    sort_dir_first = true
    show_hidden = false
    linemode = "size"

    [preview]
    # Large dimensions to use full preview pane
    max_width = 4000
    max_height = 2000

    [opener]
    # Play videos and GIFs with mpv (opens as floating window)
    play = [
      { run = 'mpv --loop-file=inf --geometry=50%:50% --title="yazi-mpv" "$@"', orphan = true, desc = "Play with mpv" }
    ]
    # Open regular images with default viewer
    view = [
      { run = 'xdg-open "$@"', orphan = true, desc = "Open with default app" }
    ]

    [open]
    rules = [
      { mime = "video/*", use = "play" },
      { mime = "image/gif", use = "play" },
      { mime = "image/*", use = "view" },
    ]
  '';

  # Configure yazi theme for better preview visibility
  xdg.configFile."yazi/theme.toml".text = ''
    [mgr]
    border_style = { fg = "blue" }
  '';

  # Install f3d-preview plugin for 3D model previews (STL, 3MF, OBJ, STEP)
  home.activation.installYaziPlugins = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # Clone f3d-preview plugin if not exists
    PLUGIN_DIR="$HOME/.config/yazi/plugins/f3d-preview.yazi"
    if [ ! -d "$PLUGIN_DIR" ]; then
      $DRY_RUN_CMD mkdir -p "$(dirname "$PLUGIN_DIR")"
      $DRY_RUN_CMD ${pkgs.git}/bin/git clone https://github.com/Ruudjhuu/f3d-preview.yazi.git "$PLUGIN_DIR"
    else
      $DRY_RUN_CMD cd "$PLUGIN_DIR" && ${pkgs.git}/bin/git pull
    fi
  '';

  # Configure yazi to use f3d-preview plugin
  xdg.configFile."yazi/init.lua".text = ''
    -- Enable f3d-preview for 3D models
    require("f3d-preview"):setup()
  '';
}
