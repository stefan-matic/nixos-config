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

    zbar

    nix-prefetch-git

    terraform
    terragrunt
    opentofu

    prusa-slicer

    unstable.gnumake
    unstable.affine

    qdirstat

    # Niri/DMS utilities
    cliphist          # Clipboard history for DMS
    grim              # Screenshot utility for Wayland
    slurp             # Screen area selection for Wayland

    # Nautilus file manager support
    gvfs              # Virtual filesystem (USB devices, network shares, etc.)
    gnome-disk-utility # Disk management
  ];

  # Enable Niri wayland compositor
  programs.niri.enable = true;

  # Enable GVFS for Nautilus USB/network device support
  services.gvfs.enable = true;

  # Yubico Authenticator
  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = false;
  };

  # SSH agent - disabled when Niri is enabled (Niri uses GNOME keyring gcr-ssh-agent)
  programs.ssh.startAgent = lib.mkDefault (!config.programs.niri.enable);

  # Add udev rules for Arduino permissions
  services.udev.extraRules = ''
    # Arduino permissions
    SUBSYSTEM=="tty", ATTRS{idVendor}=="2341", ATTRS{idProduct}=="0043", MODE="0666", GROUP="dialout", SYMLINK+="arduino"
  '';
}


##(nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
