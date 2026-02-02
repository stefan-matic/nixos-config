{
  terminalFontSize,
  ...
}:

{
  programs.ghostty = {
    enable = true;
    settings = {
      # Theme
      theme = "dracula";

      # Font configuration - using JetBrainsMono with ligatures
      # Font size is passed from flake.nix per host: 11 for ZVIJER, 9 for others
      font-family = "JetBrainsMono Nerd Font";
      font-size = terminalFontSize;
      font-feature = [
        "-calt" # Enable contextual alternates
        "-liga" # Enable ligatures
      ];

      # Window padding for breathing room
      window-padding-x = 8;
      window-padding-y = 8;
      window-padding-balance = true;
      window-padding-color = "extend";

      # Opacity & blur effects (works great with Niri!)
      background-opacity = 0.95;
      background-blur = "20"; # Blur what's behind the window (macOS/KDE)

      # Unfocused window opacity to match Niri config
      unfocused-split-opacity = 0.85;

      # Cursor styling
      cursor-style = "block";
      cursor-style-blink = true;

      # Shell integration for better prompt detection
      shell-integration = "zsh";
      shell-integration-features = [
        "cursor"
        "sudo"
        "title"
      ];

      # Startup command - tmux with automatic session handling
      # Uses tmux new-session -A which attaches if exists or creates if not
      # This is more reliable than manual has-session checks
      command = "tmux new-session -A -s main";

      # Window decoration - let Niri handle decorations
      window-decoration = false;

      # Mouse behavior
      mouse-hide-while-typing = true;
      copy-on-select = true;

      # Performance
      window-inherit-font-size = true;

      # Better text rendering
      adjust-cell-height = "10%";
      minimum-contrast = 1.1;
    };
  };
}
