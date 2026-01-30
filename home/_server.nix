# Minimal home-manager configuration for headless servers
# No GUI applications, focused on CLI productivity
# Used as NixOS module (home-manager.users.<name>) for single-command deployment
{ pkgs, ... }:

{
  home.stateVersion = "24.11";

  imports = [
    ../user/app/git/git.nix
    ../user/app/direnv/direnv.nix
    ../user/shells/sh.nix
  ];

  news.display = "silent";

  # SSH agent for key forwarding
  services.ssh-agent.enable = true;

  # Tmux for session persistence
  programs.tmux = {
    enable = true;
    clock24 = true;
    keyMode = "vi";
    terminal = "screen-256color";
    historyLimit = 50000;
    escapeTime = 0;
    baseIndex = 1;

    extraConfig = ''
      # Mouse support
      set -g mouse on

      # Better splits
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # Vim-style pane navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Status bar
      set -g status-style 'bg=#333333 fg=#ffffff'
      set -g status-left '#[fg=#00ff00][#S] '
      set -g status-right '#[fg=#888888]%Y-%m-%d %H:%M '
      set -g status-left-length 20

      # Window status
      setw -g window-status-current-style 'fg=#00ff00 bold'

      # Reload config
      bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"
    '';
  };

  # Essential CLI tools
  home.packages = with pkgs; [
    # Modern CLI tools
    bat
    lsd
    eza
    fd
    ripgrep
    procs
    dust
    duf
    bottom
    hyperfine

    # Navigation
    zoxide
    fzf

    # Git tools
    lazygit
    delta

    # Documentation
    tldr
    glow

    # Standard utilities
    gnugrep
    gnused
    jq
    yq-go
    bc
    tree
    wget
    curl
    unzip
    zip

    # System monitoring
    htop
    iotop
    iftop
    ncdu

    # Network tools
    nmap
    netcat
    dig
    whois

    # Container tools
    docker-compose
    lazydocker
  ];

  programs.direnv.enable = true;
  programs.direnv.enableZshIntegration = true;
  programs.direnv.nix-direnv.enable = true;
}
