# Common Paneru configuration builder.
#
# Paneru is a sliding/tiling window manager for macOS and the closest thing to
# niri that exists there: windows live on an infinite horizontal strip, new
# windows never resize the existing ones, and windows stack vertically inside
# a column. Virtual workspaces map onto niri's numbered workspaces.
#
# Same shape as user/wm/niri/common.nix -- a builder called by the per-host
# file rather than a module, so host overrides replace values instead of
# merging into them.
#
# Keymap mirrors user/wm/niri/common.nix with alt (Option) standing in for
# niri's Mod (Super). cmd is unusable as Mod on macOS: cmd+q/h/w/t and
# cmd+1-5 are load-bearing system and browser shortcuts.
#
# Not translatable from niri:
#   - Spawning apps from a binding (Mod+Return ghostty, Mod+E dolphin).
#     Paneru's TOML bindings only drive window commands; Raycast is the
#     launcher, which also replaces the DMS spotlight.
#   - Screenshot binds (grim/slurp/swappy). macOS screencapture owns
#     cmd+shift+3/4/5, and Shottr covers the swappy-style annotate flow.
{
  config,
  pkgs,
  lib,
}:

{
  # Build a paneru settings attrset (rendered to TOML by the paneru module).
  #
  # Arguments:
  #   deviceType     - "laptop" or "desktop"; drives padding and gestures
  #   menuBarPadding - top inset, in px, to clear the menu bar / notch
  #   windowRules    - attrset of named per-application rules; paneru parses
  #                    `windows` as HashMap<String, WindowParams>, so this must
  #                    be a map (TOML `[windows.<name>]`), never a list
  #   extraOptions   - attrset merged over the [options] table
  mkPaneruSettings =
    {
      deviceType ? "laptop",
      menuBarPadding ? 8,
      windowRules ? { },
      extraOptions ? { },
    }:
    {
      options = {
        # niri: focus-follows-mouse + mouse warp on focus change
        focus_follows_mouse = true;
        mouse_follows_focus = true;

        # Mirrors the niri preset column widths. 0.25 is the narrow slot the
        # ZVIJER config reserves for KeePassXC/Viber/Slack side panels.
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

        # Matches `center-focused-column "never"` in user/wm/niri/common.nix.
        # With focus_follows_mouse on, enabling this re-centres the whole
        # strip on every hover, which makes windows slide around constantly.
        auto_center = false;

        # A sliver of the offscreen neighbour stays visible, the same hint
        # niri gives that there is more strip in that direction.
        sliver_width = 8;

        # Cycle back to the first preset after the last, matching niri's
        # switch-preset-column-width.
        window_resize_cycle = true;

        # Keep workspaces 1-5 around when they empty out; niri keeps its
        # named workspaces alive.
        reap_empty_workspaces = false;

        # This is a SPEED, not a duration: upstream documents 8-20 as the
        # comfortable range, and a very high value disables animations.
        animation_speed = 12;
      }
      // extraOptions;

      # Breathing room around windows, matching the niri gaps.
      padding = {
        top = menuBarPadding;
        bottom = 8;
        left = 8;
        right = 8;
      };

      # Active-window border in dracula pink, the same accent as the active
      # tmux pane border in user/app/terminal/tmux.nix.
      decorations = {
        active.border = {
          enabled = true;
          color = "#ff79c6";
          width = 2.0;
          radius = "auto";
        };
        # No dimming of unfocused windows -- the pink border alone marks
        # focus. Paneru's default opacity is 0.0, so this is left unset
        # rather than zeroed.

        # Paneru has no overview command, so the menu bar carries the
        # workspace state instead -- the closest thing to the DMS/waybar
        # workspace widget on the linux hosts.
        workspace_menu_status = true;
        workspace_popup_status = true;
        menu = {
          colors = [ "#ff79c6" ];
          descriptor = {
            style = "symbol";
            symbol = "rectangle.split.3x1";
          };
          indicator = {
            # "multi" lists every virtual workspace rather than just the
            # current one; "marked" renders the inactive ones as dots with
            # the active one as its number, e.g.  · 2 · ·
            style = "multi";
            format = "marked";
            inactive_character = "·";
            font_size = 13.0;
          };
        };
      };

      # Touchpad gestures, the niri equivalent of swiping the strip around.
      # Only wired up for laptops -- a desktop with a mouse has no trackpad.
      swipe = lib.optionalAttrs (deviceType == "laptop") {
        sensitivity = 0.4;
        deceleration = 4.0;
        # Let the strip run past the outermost window, like niri's scrollable
        # viewport, rather than snapping hard to the edge.
        continuous = true;

        gesture = {
          # FOUR fingers, not three: three-finger drag is enabled in
          # hosts/_common/darwin.nix and swallows every three-finger swipe
          # before paneru sees it. macOS' own four-finger swipes are turned
          # off there so these land here instead.
          fingers_count = 4;
          direction = "Natural";
          # Horizontal swipe scrolls the strip; vertical swipe switches
          # virtual workspace rows (niri: focus-workspace-down/up).
          vertical = true;
        };

        scroll = {
          # alt + scroll slides the strip. Mirrors the "Mod+Horizontal Scroll
          # to navigate columns" binding in user/wm/niri/laptop.nix.
          modifier = "alt";
          # alt + shift + scroll moves between workspace rows instead.
          vertical_modifier = "shift";
        };
      };

      windows = windowRules;

      # Key names come from paneru's own table (src/config.rs
      # virtual_keycode/literal_keycode): arrows are leftarrow/rightarrow/
      # uparrow/downarrow and brackets are leftbracket/rightbracket. The
      # X11-style names (left, up, bracketleft) parse but never bind, and
      # only show up as 'invalid key' lines in /tmp/paneru.err.log.
      bindings = {
        # === Focus (niri: Mod+H/J/K/L and Mod+arrows) ===
        window_focus_west = [
          "alt - h"
          "alt - leftarrow"
        ];
        window_focus_east = [
          "alt - l"
          "alt - rightarrow"
        ];
        window_focus_south = [
          "alt - j"
          "alt - downarrow"
        ];
        window_focus_north = [
          "alt - k"
          "alt - uparrow"
        ];
        window_focus_first = "alt - home";
        window_focus_last = "alt - end";

        # niri: Mod+Escape switch-focus-between-floating-and-tiling
        window_focus_managed = "alt - escape";
        window_focus_unmanaged = "alt + shift - escape";

        # === Move (niri: Mod+Shift+H/J/K/L) ===
        window_swap_west = [
          "alt + shift - h"
          "alt + shift - leftarrow"
        ];
        window_swap_east = [
          "alt + shift - l"
          "alt + shift - rightarrow"
        ];
        window_swap_south = [
          "alt + shift - j"
          "alt + shift - downarrow"
        ];
        window_swap_north = [
          "alt + shift - k"
          "alt + shift - uparrow"
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
        # niri: even out column / window sizes.
        # NOT alt-e: that is the file-manager launcher in hosts/macbook/skhd.nix
        # (niri Mod+E -> dolphin), and skhd's event tap would race paneru's.
        window_equalize = "alt + ctrl - e";
        window_balance = "alt - b";
        window_center = "alt - c";

        # === Stacking (niri: Mod+[ / Mod+] consume-or-expel-window) ===
        window_stack = "alt - leftbracket";
        window_unstack = "alt - rightbracket";

        # === Floating (niri: Mod+Shift+Space toggle-window-floating) ===
        window_manage = "alt + shift - space";
        window_raise_floating = "alt - grave";
        window_togglefloatlayer = "alt + shift - grave";

        # === Displays (niri: Mod+Shift+Left/Right move-column-to-monitor) ===
        window_nextdisplay = "alt + cmd - rightarrow";
        window_nextdisplaysend = "alt + cmd + shift - rightarrow";
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

        # Jump to the first/last workspace row.
        window_virtual_first = "alt + ctrl - home";
        window_virtual_last = "alt + ctrl - end";
        window_virtualmove_first = "alt + ctrl + shift - home";
        window_virtualmove_last = "alt + ctrl + shift - end";

        # Send a window to another row without following it -- no niri
        # equivalent, but the obvious companion to virtualmove.
        window_virtualsend_south = "alt + ctrl - pagedown";
        window_virtualsend_north = "alt + ctrl - pageup";

        # === Session (niri: Mod+Shift+Escape quit) ===
        window_snap = "alt - s";
        restart = "ctrl + alt - r";
        quit = "ctrl + alt - q";
      };
    };
}
