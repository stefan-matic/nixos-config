{
  lib,
  inputs,
  outputs,
  config,
  pkgs,
  userSettings,
  systemSettings,
  ...
}: {
  imports =
    [
      ./default.nix
      ../../system/app/virtualization.nix
      ../../system/bluetooth.nix
    ];

  # Desktop environment configuration
    services.desktopManager.plasma6.enable = true;
    services.displayManager = {
      defaultSession = "plasma";
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };

    # X11 configuration
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

  services.cloudflare-warp.enable = true;

  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget

    git

    unstable.google-chrome

    unstable.cloudflare-warp
    #cloudflare-warp
    #yubikey-personalization
    #yubikey-personalization-gui

    yubioath-flutter
    pcsclite

    gparted

    unstable.code-cursor
    #powershell #jebem te cvijo

    mesa-demos

    kdePackages.kcalc
    kdePackages.kate

    remmina

    wayfarer

    lens

    xdotool
    kdotool
    ydotool

    nix-prefetch-git

    terraform
    terragrunt
    opentofu

    prusa-slicer

    unstable.gnumake
    unstable.affine
  ];

  # Yubico Authenticator
  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = false;
  };

  programs.ssh.startAgent = true;

  # Add udev rules for Arduino permissions
  services.udev.extraRules = ''
    # Arduino permissions
    SUBSYSTEM=="tty", ATTRS{idVendor}=="2341", ATTRS{idProduct}=="0043", MODE="0666", GROUP="dialout", SYMLINK+="arduino"
  '';
}


##(nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
