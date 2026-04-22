{ config, pkgs, ... }:
let

  # My shell aliases
  # move your fish config here and bashrc
  myAliases = {
    # Modern replacements
    ls = "lsd";
    cat = "bat";
    #cd = "z"; # zoxide  Causing issues for claude not being able to use cd properly
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

    # Android
    scrcpy = "scrcpy --render-driver=opengl";

    # Utilities
    w3m = "w3m -no-cookie -v";
    neofetch = "disfetch";
    fetch = "disfetch";
    gitfetch = "onefetch";
    man = "tldr"; # Quick reference, use 'command man' for full man pages

    # DevOps
    dc = "docker compose";
    ".." = "cd ..";
    tf = "terraform";
    tg = "terragrunt";
    ks = "~/Scripts/ks"; # kube-setup for Lens
  };
in
{
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
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

      # Eye candy function for tmux startup
      eye-candy() {
        local choice=$((RANDOM % 4))
        case $choice in
          0) date "+%a %B %d, %Y" | figlet -c -f ~/.dotfiles/user/app/terminal/3d.flf | lolcat ;;
          1) fortune | cowsay | lolcat ;;
          2) fastfetch ;;
          3) figlet -c -f ~/.dotfiles/user/app/terminal/3d.flf "keep calm and rm -rf /*" | lolcat ;;
        esac
      }

      # Workspace launcher — tmux session with Claude Code for daily dev work
      # Usage: ws [session-name] [directory]
      #   ws                  → openvpn session in ~/Workspace/openvpn
      #   ws myproject ~/src  → myproject session in ~/src
      ws() {
        local session="''${1:-openvpn}"
        local workdir="''${2:-$HOME/Workspace/openvpn}"

        if tmux has-session -t "$session" 2>/dev/null; then
          if [[ -n "$TMUX" ]]; then
            tmux switch-client -t "$session"
          else
            tmux attach-session -t "$session"
          fi
          return
        fi

        # Window 1: code — VS Code-like IDE layout
        # Top: neovim with neo-tree file explorer (<leader>e to toggle)
        # Bottom: Claude Code
        tmux new-session -d -s "$session" -n code -c "$workdir"
        tmux split-window -t "$session:code" -v -l 35% -c "$workdir"
        tmux send-keys -t "$session:code.1" "nvim ." C-m
        tmux send-keys -t "$session:code.2" "claude" C-m
        tmux select-pane -t "$session:code.1"

        # Window 2: shell — primary (70%) + secondary (30%) panes
        tmux new-window -t "$session" -n shell -c "$workdir"
        tmux split-window -t "$session:shell" -v -l 30% -c "$workdir"
        tmux select-pane -t "$session:shell.1"

        # Window 3: git — dedicated git window
        tmux new-window -t "$session" -n git -c "$workdir"

        tmux select-window -t "$session:code"

        if [[ -n "$TMUX" ]]; then
          tmux switch-client -t "$session"
        else
          tmux attach-session -t "$session"
        fi
      }

      # Quick repo picker — cd into a cipherscale repo or open lazygit there
      # Usage: wr         → fzf-pick a repo and cd into it
      #        wr zordon  → cd directly into cipherscale-repos/zordon
      #        wr -g      → fzf-pick a repo and open lazygit
      wr() {
        local base="$HOME/Workspace/openvpn/cipherscale-repos"
        local use_lg=false

        if [[ "$1" == "-g" ]]; then
          use_lg=true
          shift
        fi

        local repo
        if [[ -n "$1" ]]; then
          repo="$base/$1"
        else
          repo=$(find "$base" -maxdepth 1 -mindepth 1 -type d | sort | fzf --height=40% --reverse --header="Select repo")
          [[ -z "$repo" ]] && return 0
        fi

        if [[ ! -d "$repo" ]]; then
          echo "Not found: $repo" >&2
          return 1
        fi

        if [[ "$use_lg" == true ]]; then
          lazygit -p "$repo"
        else
          cd "$repo"
        fi
      }

      # Connect to Android phone via wireless ADB + scrcpy
      # Usage: phone [ip]  (defaults to 10.100.10.195)
      phone() {
        local ip="''${1:-10.100.10.195}"
        local port=5555
        echo "Connecting to $ip:$port..."
        adb connect "$ip:$port"
        scrcpy --render-driver=opengl
      }

      # Set terminal title for SSH sessions (helps tmux show hostname)
      # This runs on every prompt, updating the title
      function set_terminal_title() {
        if [[ -n "$SSH_CONNECTION" ]]; then
          # We're in an SSH session, show user@host
          print -Pn "\e]2;%n@%m: %~\a"
        else
          # Local session, show just the directory
          print -Pn "\e]2;%~\a"
        fi
      }
      precmd_functions+=(set_terminal_title)

      #https://terminalroot.com/how-to-optimize-the-cd-command-to-go-back-multiple-folders-at-once/
      # Override cd to support `cd -N` for going back N directories
      # e.g. `cd -3` is equivalent to `cd ../../../`
      cd() {
        if [[ "$1" =~ ^-[0-9]+$ ]]; then
          local n=''${1#-}
          local path=""
          for ((i=0; i<n; i++)); do
            path+="../"
          done
          builtin cd "$path"
        else
          builtin cd "$@"
        fi
      }

      # fzf-tab - must be sourced after compinit (oh-my-zsh runs compinit)
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh

      # fzf-tab configuration
      # Always use fzf, even for few completions
      zstyle ':fzf-tab:*' fzf-min-height 15
      # Disable default zsh completion menu
      zstyle ':completion:*' menu no
      # Preview directory contents
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd -1 --color=always $realpath'
      # Preview file contents
      zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always --style=numbers --line-range=:500 $realpath 2>/dev/null || lsd -1 --color=always $realpath 2>/dev/null || echo $word'
      # Switch group with < and >
      zstyle ':fzf-tab:*' switch-group '<' '>'
      # Disable sorting for kubectl completion (preserves resource order)
      zstyle ':completion:*:kubectl-*:*' sort false

      # AWS Profile switcher (like kubectx but for AWS)
      # Respects direnv - uses AWS_CONFIG_FILE set by .envrc
      awsp() {
        if [[ -z "$AWS_CONFIG_FILE" ]]; then
          echo "AWS_CONFIG_FILE not set. Are you in a project directory with direnv?" >&2
          return 1
        fi

        if [[ ! -f "$AWS_CONFIG_FILE" ]]; then
          echo "AWS config not found: $AWS_CONFIG_FILE" >&2
          return 1
        fi

        # Get list of profiles from config file
        local profiles
        profiles=$(grep -oP '(?<=\[profile )[^\]]+' "$AWS_CONFIG_FILE" 2>/dev/null | sort)

        if [[ -z "$profiles" ]]; then
          echo "No profiles found in $AWS_CONFIG_FILE" >&2
          return 1
        fi

        local selected
        if [[ -n "$1" ]]; then
          # Profile provided as argument
          selected="$1"
          if ! echo "$profiles" | grep -qx "$selected"; then
            echo "Profile '$selected' not found. Available profiles:" >&2
            echo "$profiles" | sed 's/^/  /' >&2
            return 1
          fi
        else
          # Interactive selection with fzf
          selected=$(echo "$profiles" | fzf --height=40% --reverse --header="Select AWS Profile (current: ''${AWS_PROFILE:-none})")
          [[ -z "$selected" ]] && return 0
        fi

        export AWS_PROFILE="$selected"
        echo "Switched to AWS profile: $AWS_PROFILE"
      }

      # Unset AWS profile
      awsp-unset() {
        unset AWS_PROFILE
        echo "AWS_PROFILE unset"
      }
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
        "kubectl"
        "kubectx"
        "aws"
        "gcloud"
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

    # Fuzzy finder
    television # tv - modern fuzzy finder with cables (replaces many fzf workflows)
    fzf

    # Standard tools
    gnugrep
    gnused
    bc
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
