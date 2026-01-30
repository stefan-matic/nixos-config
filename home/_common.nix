# Common home-manager configuration for all client users
# Used as NixOS module (home-manager.users.<name>) for single-command deployment
{ config, ... }:

{
  home.stateVersion = "24.11";

  # Add ~/Scripts to PATH
  home.sessionPath = [ "$HOME/Scripts" ];

  imports = [
    # Application configurations (dotfiles)
    ../user/app/firefox.nix
    ../user/app/keepassxc.nix
    ../user/app/git/git.nix
    ../user/app/terminal/kitty.nix
    ../user/app/terminal/ghostty.nix
    ../user/app/terminal/yazi.nix
    ../user/app/direnv/direnv.nix
    ../user/app/browser/select-browser.nix
    ../user/app/nautilus.nix
    ../user/app/kate.nix
    ../user/app/vlc.nix
    ../user/app/prusa-slicer.nix
    ../user/app/gwenview.nix
    ../user/shells/sh.nix
    ../user/lang/python/python.nix

    # Workaround for viber being a shitty mess
    ../user/app/chat/viber.nix

    # User package lists (organized by category)
    ../user/packages/common.nix
  ];

  news.display = "silent";

  # SSH agent - systemd user service with environment variable
  # This replaces the disabled system SSH agent and GNOME keyring
  services.ssh-agent.enable = true;

  # XDG directories and user environment
  xdg.enable = true;
  xdg.mime.enable = true; # Enable MIME type handling for applications

  xdg.userDirs = {
    enable = true;
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
      XDG_DOTFILES_DIR = "${config.home.homeDirectory}/.dotfiles";
      XDG_VM_DIR = "${config.home.homeDirectory}/VMs";
      XDG_WORKSPACE_DIR = "${config.home.homeDirectory}/Workspace";
      XDG_APPLICATION_DIR = "${config.home.homeDirectory}/Applications";
    };
  };
}
