# Stefan's NixOS Config

Contains all of the configuration for all of my devices

Heavily influenced by [LibrePhoenix](https://github.com/librephoenix/nixos-config).

Brought into a sane state using Claude which fully manages the config now.

Not yet ready to be publicly released.

## Cleanup

```
nix-env --list-generations

nix-collect-garbage  --delete-old

nix-collect-garbage  --delete-generations 1 2 3

# recommeneded to sometimes run as sudo to collect additional garbage
sudo nix-collect-garbage -d

# As a separation of concerns - you will need to run this command to clean out boot
sudo /run/current-system/bin/switch-to-configuration boot
```

## Useful commands

```
nix-shell -p nix-info --run "nix-info -m"
```

### Fresh install commands

export NIX_CONFIG="experimental-features = nix-command flakes"

nix-shell -p git

sudo nixos-rebuild switch --flake ~/.dotfiles

home-manager install

NIX_SSHOPTS="-A" nixos-rebuild --flake ~/.dotfiles --target-host z420 --use-remote-sudo switch

nixos-rebuild switch --flake ~/.dotfiles#z420 --target-host z420 --use-remote-sudo

## Live boot

### Build the ISO

`nix build .#nixosConfigurations.liveboot-iso.config.system.build.isoImage`

The result will be a symlink pointing to the ISO

`ls -lh result/iso/`

The build process will:

1. Evaluate your liveboot-iso configuration
2. Build all packages and dependencies
3. Create a squashfs filesystem
4. Generate the bootable ISO image
5. Create a result symlink in your current directory

Note: This can take a while (30 minutes to a few hours) depending on:

- How many packages need to be built vs downloaded from cache
- Your internet connection speed
- Your system resources

Once complete, the ISO will be at:
result/iso/stefan-nix-live-25.11.20251202.1aab892-x86_64-linux.iso

You can then copy it and write it to a USB:

Copy to a more convenient location (optional)

`cp result/iso/\*.iso ~/Downloads/`

# Write to USB (replace /dev/sdX with your USB device - BE CAREFUL!)

sudo dd if=result/iso/\*.iso of=/dev/sdX bs=4M status=progress oflag=sync
