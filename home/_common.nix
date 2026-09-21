# Common home-manager configuration for all NixOS client users
# Used as NixOS module (home-manager.users.<name>) for single-command deployment
# Cross-platform pieces live in _core.nix (shared with darwin.nix).
{ config, ... }:

{
  imports = [
    ./_core.nix

    # Linux-only application configurations (systemd, wayland, KDE, xdg)
    ../user/app/firefox.nix
    ../user/app/keepassxc.nix
    ../user/app/browser/select-browser.nix
    ../user/app/kate.nix
    ../user/app/vlc.nix
    ../user/app/prusa-slicer.nix
    ../user/app/gwenview.nix
    ../user/app/okular.nix
    ../user/app/dolphin.nix
    ../user/app/espanso.nix
    ../user/app/fast-track-update.nix
    ../user/app/bleeding-edge-update.nix

    # Workaround for viber being a shitty mess
    ../user/app/chat/viber.nix

    # User package lists (organized by category)
    ../user/packages/common.nix
  ];

  # SSH agent - systemd user service with environment variable
  # This replaces the disabled system SSH agent and GNOME keyring
  services.ssh-agent.enable = true;

  # XDG directories and user environment
  xdg.enable = true;
  xdg.mime.enable = true; # Enable MIME type handling for applications

  xdg.userDirs = {
    enable = true;
    setSessionVariables = true;
    createDirectories = true;
    music = "${config.home.homeDirectory}/Music";
    videos = "${config.home.homeDirectory}/Videos";
    pictures = "${config.home.homeDirectory}/Pictures";
    templates = "${config.home.homeDirectory}/Templates";
    download = "${config.home.homeDirectory}/Downloads";
    documents = "${config.home.homeDirectory}/Documents";
    desktop = null;
    publicShare = null;
    extraConfig = {
      DOTFILES = "${config.home.homeDirectory}/.dotfiles";
      VM = "${config.home.homeDirectory}/VMs";
      WORKSPACE = "${config.home.homeDirectory}/Workspace";
      APPLICATION = "${config.home.homeDirectory}/Applications";
    };
  };
}
