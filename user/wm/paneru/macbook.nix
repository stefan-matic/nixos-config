{
  config,
  pkgs,
  lib,
  ...
}:

let
  # Import common Paneru configuration builder
  common = import ./common.nix { inherit config pkgs lib; };

  # macbook-specific configuration. Host analogue of user/wm/niri/laptop.nix:
  # single built-in retina display, trackpad gestures on.
  paneruSettings = common.mkPaneruSettings {
    deviceType = "laptop";

    # Per-application rules. `title` is a required regex; `bundle_id` narrows
    # the match to one app. Get an app's id with:
    #   osascript -e 'id of app "Slack"'
    #
    # No open-on-workspace equivalent here, deliberately. paneru's
    # WindowParams (src/config.rs) has only floating/manage/index/width/grid/
    # dont_focus/padding/border_radius -- no workspace field. Assigning an app
    # to a workspace is only possible from a Lua `window_spawned` handler, and
    # an init.lua "disables the TOML entirely" (src/config.rs:49), so it would
    # mean porting all 62 bindings, rules and gestures to generated Lua.
    # Decided against 2026-09-21: assign by hand with alt+shift-1..5 instead.
    #
    # `index` is the partial alternative -- it pins where an app lands in the
    # strip, so ordering stays predictable even without workspace pinning.
    # Keys are arbitrary rule names; paneru deserialises `windows` as
    # HashMap<String, WindowParams>, rendering as TOML [windows.<name>].
    windowRules = {
      # Utility windows that should float rather than join the strip.
      # Tiled in a narrow column, matching the ZVIJER niri rule
      # (default-column-width proportion 0.20). Widened slightly here: 20%
      # of a 14" laptop is far narrower than 20% of a 57" ultrawide.
      keepassxc = {
        title = ".*";
        bundle_id = "org.keepassxc.keepassxc";
        width = 0.25;
      };
      system-settings = {
        title = ".*";
        bundle_id = "com.apple.systempreferences";
        floating = true;
      };
      finder = {
        title = ".*";
        bundle_id = "com.apple.finder";
        floating = true;
      };

      # Raycast is the launcher (niri: Mod+Space spotlight). Never tile it and
      # never steal focus from it.
      raycast = {
        title = ".*";
        bundle_id = "com.raycast.macos";
        manage = false;
        dont_focus = true;
      };

      # Chat gets the narrow slot, the same role Slack/Viber/KeePassXC have in
      # the ZVIJER niri config.
      slack = {
        title = ".*";
        bundle_id = "com.tinyspeck.slackmacgap";
        width = 0.33;
      };

      # Terminal and editor open at half width, the working default.
      ghostty = {
        title = ".*";
        bundle_id = "com.mitchellh.ghostty";
        width = 0.5;
      };
      cursor = {
        title = ".*";
        bundle_id = "com.todesktop.230313mzl4w4u92";
        width = 0.5;
      };
    };
  };
in
{
  services.paneru = {
    enable = true;
    settings = paneruSettings;
  };
}
