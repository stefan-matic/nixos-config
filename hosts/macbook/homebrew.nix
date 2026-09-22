{ ... }:

{
  # GUI applications live here rather than in home.packages: nixpkgs barely
  # packages macOS app bundles, and the few it does ship do not register with
  # Launch Services, which breaks `open -a`, the default-browser mapping set
  # with duti, and login items.
  #
  # nix-darwin does NOT install Homebrew -- see docs/macos-setup.md. It only
  # runs `brew bundle` against the list below.
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      # "uninstall" / "zap" would remove every cask not listed here. Left at
      # "none" on purpose: a work machine picks up vendor tooling and VPN
      # clients out of band, and those must survive a rebuild.
      cleanup = "none";
    };

    casks = [
      # Terminal. user/app/terminal/ghostty.nix sets package = null on darwin
      # and only writes the config for this cask.
      "ghostty"

      # Desktop stack replacing niri + DMS
      "raycast" # DMS spotlight / launcher, bound to alt+space
      "stats" # DMS status widgets, in the menu bar
      "shottr" # swappy-style screenshot annotation
      "karabiner-elements" # input-remapper
      "espanso" # espanso-wayland

      # Browsers (user/packages/common.nix)
      "google-chrome"

      # Communication (user/packages/communication.nix)
      "slack"
      "discord"
      "element"
      "thunderbird"
      "zoom"

      # Productivity and media (user/packages/common.nix + productivity.nix)
      "keepassxc"
      "libreoffice"
      "vlc"
      "qbittorrent"
      "rustdesk"
    ];
  };
}
