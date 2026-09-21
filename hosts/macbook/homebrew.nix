{ ... }:

{
  # GUI applications for the macbook.
  #
  # These are the counterparts to the linux GUI packages in
  # user/packages/{common,communication,productivity}.nix. They come from
  # Homebrew rather than nixpkgs because nixpkgs either doesn't build them for
  # darwin at all, or builds them in a way Launch Services and the macOS
  # permission system (Accessibility, Screen Recording, Input Monitoring)
  # can't grant permissions to.
  #
  # nix-darwin drives the existing /opt/homebrew install; it does not install
  # Homebrew itself. Run `brew update` once before the first darwin-rebuild.

  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      # "uninstall" removes casks dropped from this list but leaves anything
      # installed by hand alone. "zap" would also nuke their app data, and
      # "none" would let removals silently linger.
      cleanup = "uninstall";
    };

    # No taps or brews: paneru comes from its nix flake module, and every
    # other CLI tool is a nix package. Casks only.

    casks = [
      # === Terminal ===
      # nixpkgs builds ghostty for linux only; home-manager still writes
      # ~/.config/ghostty/config via user/app/terminal/ghostty.nix.
      "ghostty"

      # === Window management / desktop shell ===
      # paneru itself is installed by its nix-darwin module, not here.
      #
      # Raycast replaces the DMS spotlight (Mod+Space launcher). Deliberately
      # the FREE tier: the launcher, snippets, quicklinks and the extension
      # store are free forever for individuals. Pro ($10/mo) is essentially
      # Raycast AI plus cloud sync -- not needed here. It is proprietary,
      # which is why clipboard history is Maccy's job (MIT) rather than
      # Raycast's: that also sidesteps the free tier's 3-month clipboard
      # retention cap.
      "raycast"
      # Menu bar system monitor - the DMS status widgets equivalent.
      "stats"
      # Screenshot + annotate, replacing grim/slurp/swappy.
      "shottr"
      # Clipboard history incl. images, replacing cliphist + the DMS
      # clipboard widget. nixpkgs has maccy and it builds on darwin, but a
      # store-path .app breaks macOS TCC: the path changes on every version
      # bump, so the Accessibility grant Maccy needs for paste-on-select is
      # silently lost each rebuild. Cask keeps a stable /Applications path.
      "maccy"
      # Key remapping, replacing input-remapper.
      "karabiner-elements"
      # Windows/linux-style switcher: one entry per WINDOW, not per app.
      # macOS cmd-tab switches applications and cmd-` cycles windows within
      # one app; neither matches the niri/KDE behaviour. Owns alt-tab, which
      # is why skhd's overview binding moved to alt-o.
      "alt-tab"
      # Dual-pane, keyboard-driven file manager. Finder cannot do dual pane
      # or Dolphin-style keys at all; this is the actual replacement.
      "marta"

      # === Browsers ===
      # Finicky is the default http handler and routes URLs to the right
      # Chrome profile. Darwin replacement for pkgs/select-browser; its
      # rules live in user/app/browser/finicky.nix.
      "finicky"
      "google-chrome"
      "brave-browser"
      "firefox"

      # === Editors & IDEs ===
      "cursor"
      "visual-studio-code"
      "zed"
      "dbeaver-community"

      # === DevOps ===
      "docker-desktop"
      "lens"
      "bruno"

      # === Phone integration ===
      # KDE Connect, matching services.kdeconnect on the linux hosts. Only
      # available as a cask: nixpkgs' kdePackages.kdeconnect-kde is linux
      # only, and home-manager's services.kdeconnect asserts platforms.linux.
      "kde-connect"

      # === Communication (user/packages/communication.nix) ===
      "slack"
      "discord"
      "element"
      "thunderbird"

      # === Security & VPN (user/packages/productivity.nix) ===
      "keepassxc"
      "tailscale-app"
      "protonvpn"

      # === Productivity (user/packages/common.nix, creative.nix) ===
      "libreoffice"
      "vlc"
      "drawio"
      "espanso" # text expander; espanso-wayland on linux
    ];
  };
}
