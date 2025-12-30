{ config, pkgs, userSettings, ... }:

{
  nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true;

  home.stateVersion = "24.11";
  home.username = userSettings.username;
  home.homeDirectory = "/home/"+userSettings.username;

  imports = [
    # Application configurations (dotfiles)
    ../user/app/keepassxc.nix
    ../user/app/git/git.nix
    ../user/app/terminal/kitty.nix
    ../user/app/terminal/ghostty.nix
    ../user/app/direnv/direnv.nix
    ../user/app/browser/select-browser.nix
    ../user/app/nautilus.nix
    ../user/app/kate.nix
    ../user/shells/sh.nix
    ../user/lang/python/python.nix

    # Workaround for viber being a shitty mess
    ../user/app/chat/viber.nix

    # User package lists (organized by category)
    ../user/packages/common.nix
  ];

  news.display = "silent";

  # XDG directories and user environment
  xdg.enable = true;
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
