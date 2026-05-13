{ pkgs, ... }:

{
  # Auto-update nixpkgs-bleeding-edge flake input on login.
  # Next rebuild picks up the latest versions for bleeding-edge.* packages.
  # Tracks nixpkgs master — no Hydra gate, occasional breakage expected.
  systemd.user.services.bleeding-edge-update = {
    Unit = {
      Description = "Update nixpkgs-bleeding-edge flake input";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.nix}/bin/nix flake update nixpkgs-bleeding-edge --flake %h/.dotfiles";
      StandardOutput = "journal";
      StandardError = "journal";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
