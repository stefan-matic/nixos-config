{ config, pkgs, userSettings, ... }:

{
  programs.home-manager.enable = true;

  home.stateVersion = "24.11";
  home.username = userSettings.username;
  home.homeDirectory = "/home/"+userSettings.username;

	imports = [
    ../user/app/keepassxc.nix
    ../user/app/git/git.nix
    ../user/app/terminal/kitty.nix
    ../user/lang/python/python.nix
    #../user/app/direnv/direnv.nix
    ../user/shells/sh.nix
    ../user/style/stylix.nix # Styling and themes for my apps
    ../user/wm/hyprland/hyprland.nix
    ../user/wm/hyprland/hyprpaper.nix
    ../user/wm/hyprland/hyprlock.nix
    ../user/app/waybar/waybar.nix
    ../user/app/browser/chrome.nix
  ];

  news.display = "silent";

  home.packages =
    with pkgs; [
      chromium
      firefox
      vscode

      # archives
      zip
      xz
      unzip
      #p7zip

      # utils
      kdeconnect
      which
      tree
      gnupg

      # network tools
      ipcalc
      ldns
      
      # monitors
      btop
      iotop
      iftop

      #system call monitors
      strace
      ltrace
      lsof

      # system tools
      lm_sensors
      pciutils
      usbutils

      # Za waybar sound control
      pavucontrol
      pamixer
      # brightness
      brightnessctl

      vlc
      flameshot
      wl-clipboard
      grim
      slurp
      tesseract4


      (pkgs.writeScriptBin "screenshot-ocr" ''
      #!/bin/sh
      imgname="/tmp/screenshot-ocr-$(date +%Y%m%d%H%M%S).png"
      txtname="/tmp/screenshot-ocr-$(date +%Y%m%d%H%M%S)"
      txtfname=$txtname.txt
      grim -g "$(slurp)" $imgname;
      tesseract $imgname $txtname;
      wl-copy -n < $txtfname
    '')

    ];

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
        XDG_VM_DIR = "${config.home.homeDirectory}/Machines";
        XDG_WORKSPACE_DIR = "${config.home.homeDirectory}/Workspace";
        XDG_APPLICATION_DIR = "${config.home.homeDirectory}/Applications";
      };
    };
}


