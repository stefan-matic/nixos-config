{ config, pkgs, inputs, userSettings, systemSettings, ... }:

{
  imports =
    [
      ./server.nix
      ../../system/app/virtualization.nix
    ];


  services.cloudflare-warp.enable = true;

  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget

    git

    unstable.cloudflare-warp
    #cloudflare-warp
    #yubikey-personalization
    #yubikey-personalization-gui

    yubioath-flutter
    pcsclite

    gparted

    unstable.code-cursor
    powershell

    glxinfo

    kdePackages.kcalc
  ];

  fonts.packages = with pkgs; [
    font-awesome
    fira-code
    fira-code-symbols
    powerline-fonts
    powerline-symbols
  ];


  # OBS VIRTUAL CAM
  boot = {
    extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
    extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
    '';
  };
  security.polkit.enable = true;

  # Yubico Authenticator
  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = false;
  };

  programs.ssh.startAgent = true;

}


##(nerdfonts.override { fonts = [ "JetBrainsMono" ]; })