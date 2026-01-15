{ pkgs, ... }:
let

  # My shell aliases
  # move your fish config here and bashrc
  myAliases = {
    # Modern replacements
    ls = "lsd";
    cat = "bat";
    cd = "z"; # zoxide
    find = "fd";
    grep = "rg";
    ps = "procs";
    du = "dust";
    df = "duf";

    # File management
    fm = "yazi"; # Terminal file manager

    # Enhanced commands
    #htop = "btm";
    fd = "fd -Lu";

    # Git
    lg = "lazygit";

    # Utilities
    w3m = "w3m -no-cookie -v";
    neofetch = "disfetch";
    fetch = "disfetch";
    gitfetch = "onefetch";
    man = "tldr"; # Quick reference, use 'command man' for full man pages

    # DevOps
    "," = "comma";
    tf = "terraform";
    tg = "terragrunt";
  };
in
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    shellAliases = myAliases;
    initContent = ''
      PROMPT=" ◉ %U%F{magenta}%n%f%u@%U%F{blue}%m%f%u:%F{yellow}%~%f
       %F{green}→%f "
      RPROMPT="%F{red}▂%f%F{yellow}▄%f%F{green}▆%f%F{cyan}█%f%F{blue}▆%f%F{magenta}▄%f%F{white}▂%f"
      [ $TERM = "dumb" ] && unsetopt zle && PS1='$ '

      # FZF integration
      source <(fzf --zsh)

      # Zoxide integration (replaces z)
      eval "$(zoxide init zsh)"
    '';

    plugins = [
      {
        name = "powerlevel10k-config";
        src = ./p10k;
        file = "p10k.zsh";
      }
      {
        name = "zsh-powerlevel10k";
        src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/";
        file = "powerlevel10k.zsh-theme";
      }
    ];

    oh-my-zsh = {
      enable = true;
      # Standard OMZ plugins pre-installed to $ZSH/plugins/
      # Custom OMZ plugins are added to $ZSH_CUSTOM/plugins/
      # Enabling too many plugins will slowdown shell startup
      plugins = [
        "git"
        "sudo" # press Esc twice to get the previous command prefixed with sudo https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/sudo
        # Removed "z" - replaced by zoxide
        "terraform"
        "systemadmin"
        "fzf"
        "kubectx"
      ];
      extraConfig = ''
        # Display red dots whilst waiting for completion.
        COMPLETION_WAITING_DOTS="true"
      '';
    };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = myAliases;
  };

  home.packages = with pkgs; [
    # System info & fetch tools
    disfetch
    lolcat
    cowsay
    onefetch
    fastfetch # Fast neofetch alternative

    # ASCII art generators
    figlet # 3D ASCII text
    toilet # Enhanced figlet with more fonts
    fortune # Random quotes

    # Modern CLI tools (rust-based alternatives)
    bat # cat with syntax highlighting
    lsd # LSDeluxe - modern ls replacement
    eza # Another modern ls
    fd # Modern find alternative
    ripgrep # Modern grep (rg)
    procs # Modern ps replacement
    dust # Modern du (disk usage)
    duf # Modern df (disk free)
    bottom # Modern top/htop (btm)
    hyperfine # Benchmarking tool

    # Navigation & file management
    zoxide # Smarter cd with learning
    # yazi - managed via programs.yazi in user/app/terminal/yazi.nix
    chafa # Image viewer for terminal

    # Git tools
    lazygit # Terminal UI for git
    delta # Beautiful git diffs

    # Documentation & helpers
    tldr # Simplified man pages
    glow # Markdown viewer

    # Standard tools
    gnugrep
    gnused
    fzf
    bc
    direnv
    nix-direnv
    jq
    yq-go

    # Media support for terminal file manager
    ffmpegthumbnailer # Video thumbnails for yazi
    ueberzugpp # Image display in terminal for yazi
    poppler-utils # PDF preview (pdftotext)
    imagemagick # Image processing
  ];

  programs.direnv.enable = true;
  programs.direnv.enableZshIntegration = true;
  programs.direnv.nix-direnv.enable = true;
}
