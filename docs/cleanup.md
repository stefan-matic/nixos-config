# NixOS Cleanup Guide

Manage generations and disk space.

## Quick Cleanup

```bash
# Monthly cleanup (recommended)
sudo nix-collect-garbage --delete-older-than 30d
nix-collect-garbage --delete-older-than 30d
home-manager expire-generations "-30 days"
sudo /run/current-system/bin/switch-to-configuration boot
```

## Emergency Space Recovery

```bash
# Keep only current generation
sudo nix-env --delete-generations old --profile /nix/var/nix/profiles/system
nix-env --delete-generations old
sudo nix-collect-garbage -d
sudo /run/current-system/bin/switch-to-configuration boot
nix-store --optimize
```

## List Generations

```bash
# System
sudo nixos-rebuild list-generations

# Home Manager
home-manager generations
```

## Delete Specific Generations

```bash
# System (by number)
sudo nix-env --delete-generations 42 43 --profile /nix/var/nix/profiles/system

# Home Manager (by days)
home-manager expire-generations "-7 days"
```

## Check Disk Usage

```bash
du -sh /nix/store                    # Store size
nix path-info --all --size -h | sort -k2 -h | tail -20  # Largest paths
```

## Automatic Cleanup

Already configured in system:

```nix
nix.gc = {
  automatic = true;
  options = "--delete-older-than 30d";
};
nix.optimise.automatic = true;
```
