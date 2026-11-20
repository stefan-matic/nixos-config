# Home-manager configuration for Darwin (macOS) hosts.
#
# Counterpart to home/stefanmatic.nix. Shares the cross-platform base in
# _core.nix (shell, git, neovim, tmux, yazi, languages) and adds the darwin
# replacements for the linux-only pieces.
{
  config,
  pkgs,
  ...
}:

{
  imports = [
    ./_core.nix

    # Window manager - paneru stands in for niri
    ../user/wm/paneru/macbook.nix

    # Darwin replacements for linux-only modules
    ../user/app/browser/finicky.nix # URL router; replaces select-browser
    ../user/app/karabiner.nix # Dolphin-style Finder keybindings
    ../user/app/keybindings.nix # linux-style ctrl word navigation
    ./services/syncthing-darwin.nix # replaces the hand-run docker container
    ../user/app/flake-update-darwin.nix # systemd user timers -> launchd agents
    ../user/packages/darwin.nix # user/packages/common.nix minus GUI apps

    # Portable package categories. development.nix filters its own linux-only
    # entries. gaming.nix and creative.nix are omitted entirely: this is a
    # work machine and both are wine/KDE/CUDA bound. communication.nix is
    # omitted because every app in it is a cask on darwin.
    ../user/packages/development.nix
  ];

  # Screenshot destination declared in hosts/_common/darwin.nix
  home.file."Pictures/Screenshots/.keep".text = "";

  # GPG through the macOS keychain prompt rather than pinentry-gnome3.
  # home-manager's services.gpg-agent module is systemd-only, so the agent is
  # configured by file and started on demand by gpg itself.
  programs.gpg.enable = true;
  home.file.".gnupg/gpg-agent.conf".text = ''
    pinentry-program ${pkgs.pinentry_mac}/bin/pinentry-mac
    default-cache-ttl 3600
    max-cache-ttl 28800
  '';

  # NOTE: deliberately no programs.ssh here. ~/.ssh/config is carried by
  # syncthing from the linux hosts (see home/services/syncthing-darwin.nix),
  # and none of them use home-manager for it either. Enabling it would make
  # ~/.ssh/config a /nix/store symlink, which syncthing would then push to
  # UNRAID as a path that resolves on no other machine.
  #
  # For macOS keychain integration add this to the *synced* config instead --
  # IgnoreUnknown keeps it harmless on linux:
  #   Host *
  #     IgnoreUnknown UseKeychain
  #     AddKeysToAgent yes
  #     UseKeychain yes

  # Default browser and URL handling. On linux this is xdg.mimeApps pointing
  # at select-browser (user/app/browser/select-browser.nix); macOS keeps the
  # mapping in Launch Services, so it is set imperatively with duti once.
  #   duti -s com.google.Chrome public.html all
  home.sessionVariables = {
    BROWSER = "open";
  };

  # XDG base directories. home-manager enables these on darwin too, and the
  # nix-managed tools (yazi, ghostty, zsh, task) all write under ~/.config.
  xdg.enable = true;
}
