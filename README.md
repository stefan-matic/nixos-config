# Stefan's NixOS Config

Flake-based NixOS configuration for multiple hosts.

Heavily influenced by [LibrePhoenix](https://github.com/librephoenix/nixos-config).

Brought into a sane state using Claude which drives majority of the config now.
No vibe-coding, just clean spec-driven development.

## Hosts

| Host            | Type    | Description                           |
| --------------- | ------- | ------------------------------------- |
| ZVIJER          | Desktop | Gaming/workstation with dual monitors |
| stefan-t14      | Laptop  | Lenovo ThinkPad T14                   |
| starlabs        | Laptop  | StarLabs laptop                       |
| z420            | Server  | HP Z420 workstation                   |
| dell-micro-3050 | Server  | Dell Micro home lab                   |

## Quick Start

```bash
# System rebuild
sudo nixos-rebuild switch --flake ~/.dotfiles#ZVIJER

# Home Manager (host-specific)
home-manager switch --flake ~/.dotfiles#stefanmatic@ZVIJER

# Remote server deployment
nixos-rebuild switch --flake ~/.dotfiles#dell-micro-3050 \
  --target-host sysmatic@dell-micro-3050 --use-remote-sudo
```

## Structure

```
hosts/           # Host configurations
  _common/       # Shared (default.nix, client.nix, server.nix)
  zvijer/        # Desktop config
  t14/           # Laptop config
  ...
home/            # Home Manager configs
user/            # User apps, shells, packages
system/          # System modules (packages, security)
pkgs/            # Custom packages
docs/            # Documentation
```

## Cleanup

```bash
sudo nix-collect-garbage --delete-older-than 30d
sudo /run/current-system/bin/switch-to-configuration boot
```

## Live ISO

```bash
nix build .#nixosConfigurations.liveboot-iso.config.system.build.isoImage
sudo dd if=result/iso/*.iso of=/dev/sdX bs=4M status=progress
```

## Docs

See `docs/` for guides on server deployment, home-manager, devbox, cleanup, etc.
