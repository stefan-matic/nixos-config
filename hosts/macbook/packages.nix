{ pkgs, ... }:

{
  # macbook-specific system packages.
  #
  # Darwin counterpart to hosts/zvijer/packages.nix. Almost everything that is
  # a *system* package on NixOS (hardware daemons, udev helpers, desktop
  # infrastructure) has no darwin equivalent, so this stays small -- user
  # tooling belongs in home-manager via home/darwin.nix.

  environment.systemPackages = with pkgs; [
    # Keep the flake's own toolchain available to root for darwin-rebuild
    git
    nixfmt
  ];
}
