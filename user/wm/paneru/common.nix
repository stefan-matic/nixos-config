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
  # Deliberately thin: every option upstream gives a default is left unset, so
  # this is the behaviour paneru's author intended plus the niri-shaped
  # keymap. The tuned values that used to live here (animation_speed, swipe
  # sensitivity/deceleration, padding, decorations, preset widths, sliver,
  # auto_center) were dropped 2026-09-22 -- together they made windows jump
  # sideways on focus changes. Re-add one at a time, never as a batch, and
  # read the default in upstream's CONFIGURATION.md before overriding it.
  #
  # Arguments:
  #   deviceType   - "laptop" or "desktop"; laptops get the trackpad gesture
  #   windowRules  - attrset of named per-application rules; paneru parses
  #                  `windows` as HashMap<String, WindowParams>, so this must
  #                  be a map (TOML `[windows.<name>]`), never a list
  #   extraOptions - rendered as the [options] table, empty by default
  mkPaneruSettings =
    {
      deviceType ? "laptop",
      windowRules ? { },
      extraOptions ? { },
    }:
    {
      # The [options] table is emitted even when empty, and must stay that
      # way. Upstream declares it `#[serde(default)] options: MainOptions`
      # (src/config.rs:1063), so an ABSENT table builds MainOptions via the
      # derived Default -- and the derived Default ignores the per-field
      # `#[serde(default = "default_preset_column_widths")]` at
      # src/config.rs:1184, leaving preset_column_widths an empty Vec.
      # window_resize then falls through to `widths.first().unwrap_or(&0.5)`
      # (src/commands.rs:762) and pins every window at 50% forever. An empty
      # table deserialises normally, so the real defaults apply.
      options = extraOptions;
    }
    // lib.optionalAttrs (deviceType == "laptop") {
      # The one deliberate non-default. Paneru ignores the trackpad entirely
      # until fingers_count is set (>= 3), so leaving it out would mean no
      # swipe at all. THREE fingers: hosts/_common/darwin.nix turns macOS'
      # own three-finger swipes off and moves Mission Control / App Expose
      # to four fingers vertical. Horizontal scrolls the strip, vertical
      # switches virtual workspace rows.
      swipe.gesture.fingers_count = 3;

      # Default 0.35 flung the strip from one end to the other on a modest
      # swipe. Sensitivity scales both the direct drag distance and the
      # inertia velocity (src/ecs/scroll.rs), so lowering it tames both. It
      # also raises the vertical workspace-switch threshold (0.15 / value),
      # which helps keep stray vertical motion from changing rows.
      # Deceleration stays at its default; raise it next if inertia still
      # carries too far.
      swipe.sensitivity = 0.2;
    }
    // {
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
