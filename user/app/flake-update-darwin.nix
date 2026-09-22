{ config, pkgs, ... }:

{
  # Darwin equivalent of user/app/fast-track-update.nix and
  # user/app/bleeding-edge-update.nix, which are systemd user services.
  #
  # launchd has no oneshot-at-login type, so RunAtLoad fires the job once when
  # the agent is loaded (login) and StartInterval re-runs it daily for machines
  # that stay logged in for weeks. The next darwin-rebuild picks up whatever
  # the update pulled.

  launchd.agents.fast-track-update = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.nix}/bin/nix"
        "flake"
        "update"
        "nixpkgs-fast-track"
        "--flake"
        "${config.home.homeDirectory}/.dotfiles"
      ];
      RunAtLoad = true;
      StartInterval = 86400; # daily
      StandardOutPath = "${config.home.homeDirectory}/.local/state/fast-track-update.log";
      StandardErrorPath = "${config.home.homeDirectory}/.local/state/fast-track-update.log";
    };
  };

  # Tracks nixpkgs master - no Hydra gate, occasional breakage expected.
  launchd.agents.bleeding-edge-update = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.nix}/bin/nix"
        "flake"
        "update"
        "nixpkgs-bleeding-edge"
        "--flake"
        "${config.home.homeDirectory}/.dotfiles"
      ];
      RunAtLoad = true;
      StartInterval = 86400; # daily
      StandardOutPath = "${config.home.homeDirectory}/.local/state/bleeding-edge-update.log";
      StandardErrorPath = "${config.home.homeDirectory}/.local/state/bleeding-edge-update.log";
    };
  };
}
