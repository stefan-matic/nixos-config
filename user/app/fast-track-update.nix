{ pkgs, ... }:

{
  # Auto-update bleeding edge flake input on login
  # Next rebuild will pick up the latest versions
  systemd.user.services.bleeding-update = {
    Unit = {
      Description = "Update bleeding edge nixpkgs flake input";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.nix}/bin/nix flake update nixpkgs-bleeding --flake %h/.dotfiles";
      StandardOutput = "journal";
      StandardError = "journal";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
