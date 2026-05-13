{
  config,
  pkgs,
  systemSettings,
  ...
}:

let
  flakePath = "/home/stefanmatic/.dotfiles";
  hostname = systemSettings.hostname;
in
{
  systemd.services.nix-prefetch-system = {
    description = "Pre-build current NixOS configuration into the store";
    path = with pkgs; [
      nix
      nixos-rebuild
      git
    ];
    serviceConfig = {
      Type = "oneshot";
      StateDirectory = "nix-prefetch";
      WorkingDirectory = "/var/lib/nix-prefetch";
      ExecStart = "${pkgs.nixos-rebuild}/bin/nixos-rebuild build --flake ${flakePath}#${hostname}";
      Nice = 19;
      IOSchedulingClass = "idle";
      CPUSchedulingPolicy = "idle";
    };
  };

  systemd.timers.nix-prefetch-system = {
    description = "Periodic pre-build of current NixOS configuration";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "15min";
      OnUnitActiveSec = "6h";
      Persistent = true;
      RandomizedDelaySec = "30min";
    };
  };
}
