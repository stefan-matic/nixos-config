{
  lib,
  inputs,
  outputs,
  config,
  pkgs,
  userSettings,
  systemSettings,
  ...
}:
{
  imports = [
    ./default.nix
    ../../system/app/virtualization.nix
    ../../system/bluetooth.nix
    ../../system/packages/desktop.nix
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

  # Cloudflare WARP
  # services.cloudflare-warp.enable = true;

  environment.systemPackages =
    with pkgs;
    let
      customPkgs = import ../../pkgs { inherit pkgs; };
    in
    [
      # Essential system utilities
      unstable.google-chrome # One browser for system-wide access

      # Cloudflare WARP
      #unstable.cloudflare-warp

      # Custom packages (common to all client hosts)
      customPkgs.select-browser # Browser selection utility

      # Yubikey support
      yubioath-flutter
      pcsclite

      # Barcode/QR utilities (system-wide)
      zbar

      # Nix utilities
      nix-prefetch-git

      # Boot/OS tools
      os-prober # For dual-boot detection

      wl-mirror

      nixfmt-rfc-style

      # VPN tools
      wireguard-tools # WireGuard VPN support for NetworkManager

      ssh-to-age
      ragenix

    ];

  # Enable Niri wayland compositor with XWayland support
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  # Yubico Authenticator
  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = false;
    # Use pinentry-gnome3 which uses libsecret to query Secret Service (KeePassXC)
    pinentryPackage = pkgs.pinentry-gnome3;
  };

  # SSH agent - disabled when Niri is enabled (Niri uses GNOME keyring gcr-ssh-agent)
  programs.ssh.startAgent = lib.mkDefault (!config.programs.niri.enable);

  # Add udev rules for Arduino permissions
  services.udev.extraRules = ''
    # Arduino permissions
    SUBSYSTEM=="tty", ATTRS{idVendor}=="2341", ATTRS{idProduct}=="0043", MODE="0666", GROUP="dialout", SYMLINK+="arduino"
  '';
}
