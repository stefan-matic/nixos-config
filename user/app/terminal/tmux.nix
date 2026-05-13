{
  pkgs,
  ...
}:

let
  # Wifi: signal strength only (bars + dBm). Picks first wlan interface.
  wifiStatus = pkgs.writeShellScript "tmux-wifi-status" ''
    iface=$(${pkgs.iproute2}/bin/ip -o link show | ${pkgs.gawk}/bin/awk -F': ' '/wl[a-z]+[0-9]+/ {print $2; exit}')
    [ -z "$iface" ] && exit 0
    link=$(${pkgs.iw}/bin/iw dev "$iface" link 2>/dev/null)
    case "$link" in
      *"Not connected"*|"") echo " 󰖪 down "; exit 0 ;;
    esac
    signal=$(echo "$link" | ${pkgs.gawk}/bin/awk '/signal:/ {print $2; exit}')
    [ -z "$signal" ] && exit 0
    bars="▁"
    case 1 in
      $(( signal >= -50 ))) bars="▁▃▅▇" ;;
      $(( signal >= -60 ))) bars="▁▃▅" ;;
      $(( signal >= -70 ))) bars="▁▃" ;;
    esac
    printf "  %s %sdBm " "$bars" "$signal"
  '';

  # CPU usage percent (avg over 1s sample of /proc/stat).
  cpuStatus = pkgs.writeShellScript "tmux-cpu-status" ''
    read -r _ u1 n1 s1 i1 _ < /proc/stat
    t1=$((u1 + n1 + s1 + i1))
    sleep 1
    read -r _ u2 n2 s2 i2 _ < /proc/stat
    t2=$((u2 + n2 + s2 + i2))
    idle=$((i2 - i1))
    total=$((t2 - t1))
    [ "$total" -eq 0 ] && exit 0
    pct=$(( ( (total - idle) * 100 ) / total ))
    printf "  %d%% " "$pct"
  '';

  # RAM used percent from /proc/meminfo.
  ramStatus = pkgs.writeShellScript "tmux-ram-status" ''
    ${pkgs.gawk}/bin/awk '
      /^MemTotal:/  {t=$2}
      /^MemAvailable:/ {a=$2}
      END {if (t>0) printf "  %d%% ", (t-a)*100/t}
    ' /proc/meminfo
  '';

  # CPU package temperature (Celsius) from thermal_zone0 (acpitz on T14).
  tempStatus = pkgs.writeShellScript "tmux-temp-status" ''
    f=/sys/class/thermal/thermal_zone0/temp
    [ -r "$f" ] || exit 0
    ${pkgs.gawk}/bin/awk '{printf "  %.0f°C ", $1/1000}' "$f"
  '';

  # VPN indicator: lists active tun/wg interfaces (e.g. wg0, tun0, tailscale0).
  vpnStatus = pkgs.writeShellScript "tmux-vpn-status" ''
    active=$(${pkgs.iproute2}/bin/ip -o link show up | ${pkgs.gawk}/bin/awk -F': ' '/(tun|wg|tailscale|nordlynx|utun)[0-9]*:/ {print $2}' | ${pkgs.coreutils}/bin/paste -sd, -)
    [ -z "$active" ] && exit 0
    printf " 󰦝 %s " "$active"
  '';

  # Battery percent + charging state. Reads /sys, no acpi dependency.
  batteryStatus = pkgs.writeShellScript "tmux-battery-status" ''
    bat=$(${pkgs.coreutils}/bin/ls -d /sys/class/power_supply/BAT* 2>/dev/null | ${pkgs.coreutils}/bin/head -1)
    [ -z "$bat" ] && exit 0
    cap=$(${pkgs.coreutils}/bin/cat "$bat/capacity" 2>/dev/null)
    status=$(${pkgs.coreutils}/bin/cat "$bat/status" 2>/dev/null)
    case "$status" in
      Charging|Full) icon="󰂄" ;;
      Discharging)
        if [ "$cap" -ge 90 ]; then icon="󰁹"
        elif [ "$cap" -ge 70 ]; then icon="󰂀"
        elif [ "$cap" -ge 50 ]; then icon="󰁾"
        elif [ "$cap" -ge 30 ]; then icon="󰁼"
        elif [ "$cap" -ge 15 ]; then icon="󰁺"
        else icon="󰂃"
        fi
        ;;
      *) icon="󰁽" ;;
    esac
    printf " %s %s%% " "$icon" "$cap"
  '';
in

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

      # Dracula theme — colors + session icon on status-left only.
      # status-right is fully custom (see extraConfig) so we get exact layout.
      {
        plugin = dracula;
        extraConfig = ''
          set -g @dracula-show-powerline true
          set -g @dracula-plugins ""
          set -g @dracula-show-left-icon session
          set -g @dracula-show-flags true
          set -g @dracula-refresh-rate 5
        '';
      }

      # Floating scratch terminal (C-a p to toggle, C-a P for menu)
      {
        plugin = tmux-floax;
        extraConfig = ''
          set -g @floax-width '80%'
          set -g @floax-height '80%'
          set -g @floax-border-color 'magenta'
          set -g @floax-text-color 'blue'
          set -g @floax-change-path 'true'
        '';
      }

      # Easy copy to system clipboard
      yank
    ];

    extraConfig = ''
      # Enable true color support
      set -ga terminal-overrides ",*256col*:Tc"
      set -ga terminal-overrides ",ghostty:Tc"

      # Mouse scroll - 3 lines at a time instead of half page
      bind -T copy-mode-vi WheelUpPane send-keys -X -N 1 scroll-up
      bind -T copy-mode-vi WheelDownPane send-keys -X -N 1 scroll-down

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

      # Workspace launcher (C-a w) — creates or switches to openvpn dev session
      bind w if-shell 'tmux has-session -t openvpn 2>/dev/null' 'switch-client -t openvpn' 'new-session -d -s openvpn -n code -c ~/Workspace/openvpn ; split-window -t openvpn:code -v -l 35% -c ~/Workspace/openvpn ; send-keys -t openvpn:code.1 "nvim ." C-m ; send-keys -t openvpn:code.2 "claude" C-m ; select-pane -t openvpn:code.1 ; new-window -t openvpn -n shell -c ~/Workspace/openvpn ; split-window -t openvpn:shell -v -l 30% -c ~/Workspace/openvpn ; select-pane -t openvpn:shell.1 ; new-window -t openvpn -n git -c ~/Workspace/openvpn ; select-window -t openvpn:code ; switch-client -t openvpn'

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

      # === Status bar ===
      # Dracula sets colors; we own the segment layout.
      # status-left:  [session-icon] vpn wifi-signal
      # status-right: temp cpu ram battery  Tue 12 May 14:30
      set -g status-left-length 200
      set -g status-right-length 200
      set -ag status-left '#[fg=cyan]#(${vpnStatus})#[fg=green]#(${wifiStatus})#[default]'
      set -g status-right '#[fg=magenta]#(${tempStatus})#[fg=blue]#(${cpuStatus})#[fg=yellow]#(${ramStatus})#[fg=green]#(${batteryStatus})#[fg=white,bold] %a %d %b %H:%M '

      # === Eye candy on new session ===
      # Shows random ASCII art when a NEW session is created (not on attach)
      # Calls the eye-candy function defined in sh.nix
      set-hook -g session-created 'send-keys "eye-candy" Enter'
    '';
  };
}
