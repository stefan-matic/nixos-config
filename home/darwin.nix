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

  # ssh-agent is a launchd-managed system service on macOS, so the
  # services.ssh-agent module from _common.nix has no darwin equivalent.
  # Keys load from the keychain instead.
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    # Upstream ssh_config directive names -- matchBlocks/extraOptions are
    # deprecated in home-manager in favour of settings.
    settings."*" = {
      AddKeysToAgent = "yes";
      UseKeychain = "yes";
    };
  };

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
