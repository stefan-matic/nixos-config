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

        # The linux home-directory folder. Deliberately NOT ~ on this
        # machine: it carries linux dotfiles that would collide with the
        # macOS ones, and ~/.dotfiles is the flake checkout. ~/Sync already
        # holds this content and its .stfolder marker.
        "dotfiles" = {
          id = "dotfiles";
          label = "Linux - dotfiles";
          path = "${home}/Sync";
          devices = [ "unraid" ];
        };
      };
    };
  };
}
