{
  pkgs,
  lib,
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

      # Startup command - tmux with eye candy on new sessions
      # Attaches to existing 'main' session, or creates new one with random eye candy
      # Eye candy: 0=date banner, 1=fortune cow, 2=fastfetch, 3=keep calm 3D
      command =
        let
          # Escaped quotes \" so they don't close the outer zsh -c "..."
          eyeCandy = lib.concatStringsSep "" [
            ''CHOICE=$((RANDOM % 4)); ''
            ''case $CHOICE in ''
            ''0) date \"+%a %B %d, %Y\" | figlet -c -f ~/.dotfiles/user/app/terminal/3d.flf | lolcat;; ''
            ''1) fortune | cowsay | lolcat;; ''
            ''2) fastfetch;; ''
            ''3) figlet -c -f ~/.dotfiles/user/app/terminal/3d.flf \"keep calm and rm -rf /*\" | lolcat;; ''
            ''esac''
          ];
        in
        ''zsh -c "if tmux has-session -t main 2>/dev/null; then exec tmux attach -t main; else exec tmux new -s main \; send-keys '${eyeCandy}' Enter; fi"'';

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
