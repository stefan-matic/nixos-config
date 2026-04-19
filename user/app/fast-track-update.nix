{ pkgs, ... }:

{
  # Auto-update fast-track nixpkgs flake input on login.
  # Next rebuild picks up the latest versions for fast-track.* packages.
  systemd.user.services.fast-track-update = {
    Unit = {
      Description = "Update fast-track nixpkgs flake input";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.nix}/bin/nix flake update nixpkgs-fast-track --flake %h/.dotfiles";
      StandardOutput = "journal";
      StandardError = "journal";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
