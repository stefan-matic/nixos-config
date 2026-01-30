# Home-manager configuration for Android (nix-on-droid)
# Minimal configuration suitable for terminal-only Android environment
{ config, lib, pkgs, ... }:

let
  userSettings = {
    username = "nix-on-droid"; # Default nix-on-droid user
    name = "Stefan Matic";
    email = "stefanmatic94@gmail.com";
  };

  # Shell aliases suitable for Android terminal
  myAliases = {
    # Modern replacements
    ls = "lsd";
    cat = "bat";
    find = "fd";
    grep = "rg";

    # Git
    lg = "lazygit";

    # Utilities
    man = "tldr";
  };
in
{
  home.stateVersion = "24.11";

  # Git configuration
  programs.git = {
    enable = true;
    settings = {
      user.name = userSettings.name;
      user.email = userSettings.email;
      init.defaultBranch = "main";
    };
  };

  # Zsh configuration (simplified for Android)
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    shellAliases = myAliases;
    initExtra = ''
      # Starship prompt
      eval "$(starship init zsh)"

      # Zoxide integration
      eval "$(zoxide init zsh)"

      # FZF integration
      source <(fzf --zsh)
    '';
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
        "fzf"
      ];
    };
  };

  # Bash as fallback
  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = myAliases;
  };

  # Starship prompt (cross-platform, works well on Android)
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[✗](bold red)";
      };
      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
      };
      git_branch = {
        symbol = " ";
      };
      git_status = {
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
      };
      nix_shell = {
        symbol = " ";
        format = "via [$symbol$state]($style) ";
      };
    };
  };

  # Direnv for development environments
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # FZF
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # Additional packages for home environment
  home.packages = with pkgs; [
    # Text processing
    gnugrep
    gnused
    gawk

    # Networking
    netcat
    nmap

    # Misc utilities
    bc
    file
    which
    ncdu # Disk usage analyzer
  ];
}
