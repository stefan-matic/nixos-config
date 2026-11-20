{ config, ... }:

let
  unraid = "2T25XJC-SXWEDMA-DF4P57K-55AQCXQ-2MYHHLJ-IXF24KU-HNMUWRN-4W2R3AY";
  home = config.home.homeDirectory;
in
{
  # Native Syncthing, replacing the hand-created Docker container that used
  # to run this (image syncthing/syncthing, config in ~/Docker/syncthing).
  #
  # Why native rather than Docker:
  #   - home-manager's module has a real darwin branch, so this is a launchd
  #     agent that starts at login -- Docker Desktop had to be running first.
  #   - The container bind-mounted all of /Users/stefanmatic and could not
  #     create directories under the 0555 Go module cache, so the folder sat
  #     in a permission-denied retry loop every 16 minutes.
  #   - A Linux VM is a lot of machinery for one small Go daemon.
  #
  # Folder IDs must match the ones on UNRAID exactly; they are the same IDs
  # ZVIJER uses in hosts/zvijer/configuration.nix. Paths differ because this
  # is a Mac: the linux "dotfiles" folder is the whole home directory, which
  # would fight macOS' own dotfiles, so it stays parked in ~/Sync.
  services.syncthing = {
    enable = true;

    # Reuse the identity the Docker instance already had, so UNRAID sees the
    # same device rather than an unknown one needing re-approval.
    # Device ID: U7C2CIJ-562RSFS-IQRWMCH-ANQRJPC-DZBODXZ-3BIAVDM-K7N7XBQ-VZOEHQA
    cert = "${home}/Docker/syncthing/config/cert.pem";
    key = "${home}/Docker/syncthing/config/key.pem";

    # This file is the source of truth; anything added through the web GUI
    # is reverted on the next activation.
    overrideDevices = true;
    overrideFolders = true;

    settings = {
      devices.unraid.id = unraid;

      folders = {
        "Claude Code" = {
          id = "crwsq-yjurj";
          path = "${home}/.claude";
          devices = [ "unraid" ];
        };

        "Workspace" = {
          id = "cypve-yruqr";
          path = "${home}/Workspace";
          devices = [ "unraid" ];
        };

        # The home-directory folder. Despite the id it is not the flake
        # checkout -- on ZVIJER its path is /home/stefanmatic/ and an
        # allowlist .stignore narrows it to about ten dotfiles. Same shape
        # here, pointed at the real home so the paths line up with linux.
        "dotfiles" = {
          id = "dotfiles";
          label = "Linux - dotfiles";
          path = home;
          devices = [ "unraid" ];
        };
      };
    };
  };

  # Allowlist ignore pattern, mirroring the one on the linux hosts: the
  # folder is the whole home directory, and everything is ignored except the
  # handful of paths explicitly re-included with `!`. First match wins, so
  # the narrower ignores have to come before the broader includes.
  #
  # .stignore is per-device and is never itself synced, so this Mac copy can
  # legitimately differ from the linux one. Three entries have to.
  home.file.".stignore".text = ''
    // gnupg lockfiles are per-machine noise
    .gnupg/**/*.lock
    .gnupg/**/.#lk*

    // MAC-ONLY: the linux hosts have neither of these -- both are written
    // by home-manager here as /nix/store symlinks, and gpg-agent.conf points
    // at pinentry_mac which does not exist on linux. Syncing either would
    // land a dangling symlink on ZVIJER and break gpg there.
    .gnupg/gpg-agent.conf
    .gnupg/gpg.conf

    // MAC-ONLY: ~/.dotfiles is the flake checkout. Git already syncs it via
    // its remote, and this repo's own .stignore explains why syncthing must
    // not carry a git working tree alongside it.
    .dotfiles

    // Below matches the linux allowlist exactly. ~/.ssh/config and
    // ~/.gitconfig are plain synced files here, same as on the linux hosts:
    // home/darwin.nix deliberately does not use programs.ssh for that reason.
    !.gitconfig
    !.ssh
    !.aws
    !.kube
    !.z
    !.zsh_history
    !.gnupg
    !.config/espanso/match/private.yml
    !.claude.json
    **/.local/**
    **
    *
  '';
}
