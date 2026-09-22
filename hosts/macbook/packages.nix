{ pkgs, ... }:

{
  # Tiny by design. macOS ships git/curl/ssh with the Xcode command line tools,
  # and everything the user actually runs lives in the home-manager profile
  # (user/packages/darwin.nix + user/packages/development.nix). What stays
  # system-wide is only what has to work in a root shell or before
  # home-manager has been activated -- i.e. enough to rebuild the flake.
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
  ];
}
