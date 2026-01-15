{ pkgs, lib, terminalFontSize, ... }:

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

      # Startup command - random eye candy each time!
      # Cases: 0=date banner, 1=fortune cow, 2=fastfetch, 3=keep calm 3D
      command = lib.concatStringsSep " " [
        "zsh -c '"
        "CHOICE=$((RANDOM % 4));"
        "case $CHOICE in"
        ''0) date "+%a %B %d, %Y" | figlet -c -f ~/.dotfiles/user/app/terminal/3d.flf | lolcat;;''
        "1) fortune | cowsay | lolcat;;"
        "2) fastfetch;;"
        "3) figlet -c -f ~/.dotfiles/user/app/terminal/3d.flf \"keep calm and rm -rf /*\" | lolcat;;"
        "esac;"
        "exec zsh'"
      ];

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
