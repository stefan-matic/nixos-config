{
  pkgs,
  ...
}:

{
  programs.tmux = {
    enable = true;

    # Use 256 colors and true color support
    terminal = "tmux-256color";

    # Start window/pane numbering at 1 (easier to reach on keyboard)
    baseIndex = 1;

    # Increase scrollback buffer
    historyLimit = 50000;

    # Enable mouse support (scrolling, pane selection, resizing)
    mouse = true;

    # Use vi-style keybindings in copy mode
    keyMode = "vi";

    # Reduce escape time for faster response (important for vim users)
    escapeTime = 10;

    # Aggressive resize - resize to smallest client actually viewing
    aggressiveResize = true;

    # Focus events for vim/neovim autoread
    focusEvents = true;

    # Sensible prefix - Ctrl+a is easier than Ctrl+b
    prefix = "C-a";

    plugins = with pkgs.tmuxPlugins; [
      # Session persistence - saves/restores sessions across restarts
      {
        plugin = resurrect;
        extraConfig = ''
          # Restore vim/neovim sessions
          set -g @resurrect-strategy-vim 'session'
          set -g @resurrect-strategy-nvim 'session'

          # Restore pane contents
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }

      # Automatic saving/restoring (builds on resurrect)
      {
        plugin = continuum;
        extraConfig = ''
          # Auto-save every 15 minutes
          set -g @continuum-save-interval '15'

          # Auto-restore when tmux server starts
          set -g @continuum-restore 'on'

          # Show continuum status in status bar
          set -g @continuum-status 'on'
        '';
      }

      # Better pane navigation with vim-style keys
      vim-tmux-navigator

      # Dracula theme to match your ghostty
      {
        plugin = dracula;
        extraConfig = ''
          set -g @dracula-show-powerline true
          set -g @dracula-plugins "cpu-usage ram-usage time"
          set -g @dracula-show-left-icon session
          set -g @dracula-time-format "%H:%M"
          set -g @dracula-day-month true
        '';
      }

      # Easy copy to system clipboard
      yank
    ];

    extraConfig = ''
      # Enable true color support
      set -ga terminal-overrides ",*256col*:Tc"
      set -ga terminal-overrides ",ghostty:Tc"

      # Better split keybindings (more intuitive)
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # New window in current path
      bind c new-window -c "#{pane_current_path}"

      # Easy config reload
      bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"

      # Switch panes with Alt+arrow (no prefix needed)
      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D

      # Resize panes with Ctrl+Alt+arrow
      bind -n C-M-Left resize-pane -L 5
      bind -n C-M-Right resize-pane -R 5
      bind -n C-M-Up resize-pane -U 5
      bind -n C-M-Down resize-pane -D 5

      # Quick session switching
      bind s choose-tree -sZ

      # vi-style copy mode bindings
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send -X copy-selection-and-cancel

      # Don't exit copy mode on mouse release
      unbind -T copy-mode-vi MouseDragEnd1Pane

      # Renumber windows when one is closed
      set -g renumber-windows on

      # Activity monitoring
      setw -g monitor-activity on
      set -g visual-activity off

      # Faster command sequences
      set -s repeat-time 500

      # Display pane numbers longer
      set -g display-panes-time 2000

      # === Fixes for terminal passthrough ===

      # Unbind vim-tmux-navigator's C-k and C-u so nano/other apps can use them
      # (Use Alt+arrows for pane navigation instead)
      unbind -n C-k
      unbind -n C-u

      # Copy to system clipboard with Ctrl+Shift+C (in copy mode)
      bind -T copy-mode-vi C-C send -X copy-pipe-and-cancel "wl-copy"

      # Also allow mouse selection to copy to clipboard
      bind -T copy-mode-vi MouseDragEnd1Pane send -X copy-pipe-and-cancel "wl-copy"

      # === SSH hostname in window title ===
      # Automatically rename window to SSH hostname when connecting
      # The pane title is set by the shell/SSH, we just need to use it
      set -g automatic-rename on
      set -g automatic-rename-format '#{?#{==:#{pane_current_command},ssh},#{pane_title},#{pane_current_command}}'

      # Allow programs (like SSH) to set the window title
      set -g allow-rename on
      set -g set-titles on
      set -g set-titles-string '#S:#I #W - #{pane_title}'

      # === Eye candy on new session ===
      # Shows random ASCII art when a NEW session is created (not on attach)
      # Options: date banner, fortune cow, fastfetch, or keep calm message
      set-hook -g session-created 'send-keys "CHOICE=\$((RANDOM % 4)); case \$CHOICE in 0) date \"+%a %B %d, %Y\" | figlet -c -f ~/.dotfiles/user/app/terminal/3d.flf | lolcat;; 1) fortune | cowsay | lolcat;; 2) fastfetch;; 3) figlet -c -f ~/.dotfiles/user/app/terminal/3d.flf \"keep calm\" | lolcat;; esac" Enter'
    '';
  };
}
