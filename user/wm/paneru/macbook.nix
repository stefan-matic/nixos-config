# Paneru configuration for the macbook host.
#
# Counterpart to user/wm/niri/laptop.nix: the keymap, gaps and decorations are
# shared in common.nix, and only the per-machine part lives here -- the window
# rules for the applications hosts/macbook/homebrew.nix installs.
{ inputs, ... }:

{
  imports = [
    inputs.paneru.homeModules.paneru
    ./common.nix
  ];

  services.paneru.settings = {
    # Window rules. `title` is a required regex; `bundle_id` comes from
    # `osascript -e 'id of app "<name>"'` or the menu bar's Copy Window Rule.
    # Only top-level keys may be set here -- services.paneru.settings is a
    # plain attrs, so definitions merge one level deep and redefining
    # `options`/`bindings` would silently fight common.nix.
    windows = {
      # Panels that are the wrong shape for the strip. niri handles these with
      # window-rule { open-floating true; }.
      system-settings = {
        title = ".*";
        bundle_id = "com.apple.systempreferences";
        floating = true;
      };
      finder-dialogs = {
        title = "^(Copy|Move|Delete|Get Info)$";
        bundle_id = "com.apple.finder";
        floating = true;
      };
      raycast = {
        title = ".*";
        bundle_id = "com.raycast.macos";
        floating = true;
      };

      # Narrow side panels, mirroring the 0.25 preset column the ZVIJER niri
      # config reserves for KeePassXC and Slack.
      keepassxc = {
        title = ".*";
        bundle_id = "org.keepassxc.keepassxc";
        width = 0.25;
      };
      slack = {
        title = ".*";
        bundle_id = "com.tinyspeck.slackmacgap";
        width = 0.25;
      };
    };
  };
}
