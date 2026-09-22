{ pkgs, ... }:

{
  # Darwin counterpart to user/packages/common.nix.
  #
  # GUI applications are NOT here -- nixpkgs barely packages macOS app bundles,
  # and the ones it does ship don't integrate with Launch Services. Those live
  # in hosts/macbook/homebrew.nix as casks. This file is CLI only.

  home.packages = with pkgs; [
    # System Information
    fastfetch

    # Network utilities
    ipcalc
    ldns

    # Security & Encryption
    gnupg
    pinentry_mac # GPG pinentry that uses the macOS keychain prompt

    # File Management
    gdu

    # Screenshots & OCR
    tesseract4

    # Android screen mirroring & control (adb ships with android-tools)
    scrcpy
    android-tools

    # macOS default-application handler, the `xdg-mime` equivalent used by
    # user/app/browser/select-browser.nix on linux.
    duti

    # Media
    mpv

    # Nix utilities (hosts/_common/client.nix installs these system-wide on
    # linux; on darwin they belong to the user profile)
    nix-prefetch-git
    nix-prefetch-github
    nixfmt
    ssh-to-age

    # VPN tooling
    wireguard-tools
  ];
}
