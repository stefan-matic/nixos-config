# Paneru - sliding/tiling window manager for macOS.
#
# The closest thing to niri that exists on macOS: windows live on an infinite
# horizontal strip, new windows never resize the existing ones, and windows
# can be stacked vertically inside a column. Virtual workspaces map onto niri's
# numbered workspaces.
#
# Keymap mirrors user/wm/niri/common.nix with alt (Option) standing in for
# niri's Mod (Super). cmd is unusable as Mod on macOS: cmd+q/h/w/t and cmd+1-5
# are load-bearing system and browser shortcuts.
#
# Not translatable from niri:
#   - Spawning apps from a binding. Paneru's TOML bindings only drive window
#     commands; use Raycast (alt+space) as the launcher, which is also what
#     replaces the DMS spotlight.
#   - Screenshot binds (grim/slurp/swappy) -- macOS screencapture owns
#     cmd+shift+3/4/5, and Shottr is installed for the swappy-style annotate
#     flow.
{ ... }:

{
  services.paneru = {
    enable = true;

    settings = {
      options = {
        # niri: focus-follows-mouse + mouse warp on focus change
        focus_follows_mouse = true;
        mouse_follows_focus = true;

        # Mirrors the niri preset column widths. 0.25 is the narrow slot the
        # ZVIJER config reserves for KeePassXC/Slack-style side panels.
        preset_column_widths = [
          0.25
          0.33
          0.5
          0.66
          0.75
          1.0
        ];
        preset_stack_heights = [
          0.25
          0.33
          0.5
          0.66
          0.75
        ];

        # niri centers the focused column when scrolling the strip
        auto_center = true;

        # Sliver of the offscreen neighbour stays visible, like niri's
        # struts/overview hint that there is more strip in that direction.
        sliver_width = 8;

        # Cycle back to the first preset after the last, matching niri's
        # switch-preset-column-width.
        window_resize_cycle = true;

        # Don't garbage-collect workspaces 1-5 when they empty out; niri keeps
        # its named workspaces around.
        reap_empty_workspaces = false;

        animation_speed = 0.2;
      };

      # Breathing room around windows, matching the niri gaps.
      padding = {
        top = 8;
        bottom = 8;
        left = 8;
        right = 8;
      };

      # Active-window border in dracula pink, same accent as the tmux active
      # pane border in user/app/terminal/tmux.nix.
      decorations = {
        active.border = {
          enabled = true;
          color = "#ff79c6";
          width = 2.0;
          radius = "auto";
        };
        inactive.dim.opacity = 0.15;
      };

      # Three-finger swipe to scroll the strip, like niri's touchpad gestures.
      swipe = {
        sensitivity = 0.4;
        continuous = true;
        gesture = {
          fingers_count = 3;
          vertical = false;
        };
      };

      bindings = {
        # === Focus (niri: Mod+H/J/K/L and Mod+arrows) ===
        window_focus_west = [
          "alt - h"
          "alt - left"
        ];
        window_focus_east = [
          "alt - l"
          "alt - right"
        ];
        window_focus_south = [
          "alt - j"
          "alt - down"
        ];
        window_focus_north = [
          "alt - k"
          "alt - up"
        ];
        window_focus_first = "alt - home";
        window_focus_last = "alt - end";

        # niri: Mod+Escape switch-focus-between-floating-and-tiling
        window_focus_managed = "alt - escape";
        window_focus_unmanaged = "alt + shift - escape";

        # === Move (niri: Mod+Shift+H/J/K/L) ===
        window_swap_west = [
          "alt + shift - h"
          "alt + shift - left"
        ];
        window_swap_east = [
          "alt + shift - l"
          "alt + shift - right"
        ];
        window_swap_south = [
          "alt + shift - j"
          "alt + shift - down"
        ];
        window_swap_north = [
          "alt + shift - k"
          "alt + shift - up"
        ];
        window_swap_first = "alt + shift - home";
        window_swap_last = "alt + shift - end";

        # === Sizing (niri: Mod+Shift+R preset cycle, Mod+= / Mod+-) ===
        window_resize = "alt + shift - r";
        window_grow = "alt - equal";
        window_shrink = "alt - minus";
        window_vertical_grow = "alt + shift - equal";
        window_vertical_shrink = "alt + shift - minus";

        # niri: Mod+F maximize-column
        window_fullwidth = "alt - f";
        # niri: column/window height evening
        window_equalize = "alt - e";
        window_balance = "alt - b";
        # niri: Mod+C center-column
        window_center = "alt - c";

        # === Stacking (niri: Mod+[ / Mod+] consume-or-expel-window) ===
        window_stack = "alt - bracketleft";
        window_unstack = "alt - bracketright";

        # === Floating (niri: Mod+Shift+Space toggle-window-floating) ===
        window_manage = "alt + shift - space";
        window_raise_floating = "alt - grave";
        window_togglefloatlayer = "alt + shift - grave";

        # === Displays (niri: Mod+Shift+Left/Right move-column-to-monitor) ===
        window_nextdisplay = "alt + cmd - right";
        window_nextdisplaysend = "alt + cmd + shift - right";
        mouse_nextdisplay = "alt + cmd - m";

        # === Workspaces (niri: Mod+1..5, Mod+Shift+1..5) ===
        window_virtualnum_1 = "alt - 1";
        window_virtualnum_2 = "alt - 2";
        window_virtualnum_3 = "alt - 3";
        window_virtualnum_4 = "alt - 4";
        window_virtualnum_5 = "alt - 5";

        window_virtualmovenum_1 = "alt + shift - 1";
        window_virtualmovenum_2 = "alt + shift - 2";
        window_virtualmovenum_3 = "alt + shift - 3";
        window_virtualmovenum_4 = "alt + shift - 4";
        window_virtualmovenum_5 = "alt + shift - 5";

        # niri: Mod+Page_Down / Mod+Page_Up focus-workspace-down/up
        window_virtual_south = "alt - pagedown";
        window_virtual_north = "alt - pageup";
        window_virtualmove_south = "alt + shift - pagedown";
        window_virtualmove_north = "alt + shift - pageup";

        # === Session (niri: Mod+Shift+Escape quit) ===
        window_snap = "alt - s";
        restart = "ctrl + alt - r";
        quit = "ctrl + alt - q";
      };
    };
  };
}
