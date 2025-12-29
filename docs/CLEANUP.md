# NixOS Cleanup Guide

This document provides instructions for managing NixOS generations and performing cleanup operations to maintain disk space.

## Key commands highlighted:

- sudo nix-collect-garbage --delete-older-than 30d - Remove generations older than 30 days
- sudo nix-env --delete-generations old --profile /nix/var/nix/profiles/system - Keep only current generation
- sudo /run/current-system/bin/switch-to-configuration boot - Clean boot entries
- nix-store --optimize - Deduplicate files to save space

## Understanding Generations

NixOS creates a new generation each time you rebuild your system. Each generation is a complete snapshot of your system configuration, allowing you to rollback if needed.

## Listing Generations

### System Generations

```bash
# List all system generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Alternative using nixos-rebuild
sudo nixos-rebuild list-generations
```

### User Profile Generations

```bash
# List user profile generations
nix-env --list-generations

# List home-manager generations
home-manager generations
```

## Deleting Generations

### Delete Specific Generations

```bash
# Delete specific system generation (e.g., generation 42)
sudo nix-env --delete-generations 42 --profile /nix/var/nix/profiles/system

# Delete multiple generations
sudo nix-env --delete-generations 42 43 44 --profile /nix/var/nix/profiles/system

# Delete user profile generation
nix-env --delete-generations 42
```

### Delete Generations Older Than N Days

```bash
# Delete system generations older than 30 days
sudo nix-env --delete-generations +30 --profile /nix/var/nix/profiles/system

# Delete user profile generations older than 30 days
nix-env --delete-generations +30

# Delete home-manager generations older than 30 days
home-manager expire-generations "-30 days"
```

### Keep Last N Generations

```bash
# Keep only the last 5 generations (delete all others)
# This requires listing and manually selecting which to delete
# First, list generations to see which ones to keep
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Then delete old ones by number, keeping the last 5
# Example: if you have generations 1-20, delete 1-15
sudo nix-env --delete-generations 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 --profile /nix/var/nix/profiles/system
```

### Delete All Old Generations (Keep Current Only)

```bash
# Delete all old system generations except current
sudo nix-env --delete-generations old --profile /nix/var/nix/profiles/system

# Delete all old user profile generations except current
nix-env --delete-generations old
```

## Garbage Collection

After deleting generations, you must run garbage collection to actually free up disk space.

### Basic Garbage Collection

```bash
# Remove unreferenced packages (user store)
nix-collect-garbage

# Remove unreferenced packages (system-wide, requires sudo)
sudo nix-collect-garbage

# Delete all old generations AND run garbage collection
sudo nix-collect-garbage --delete-old

# More aggressive cleanup (deletes everything not currently in use)
sudo nix-collect-garbage -d
```

### Targeted Garbage Collection

```bash
# Delete generations older than 30 days and collect garbage
sudo nix-collect-garbage --delete-older-than 30d

# Delete generations older than 14 days
sudo nix-collect-garbage --delete-older-than 14d
```

## Cleaning Boot Entries

After garbage collection, update the bootloader to remove entries for deleted generations:

```bash
# Update bootloader configuration
sudo /run/current-system/bin/switch-to-configuration boot
```

## Complete Cleanup Workflow

### Recommended Monthly Cleanup

```bash
# 1. List current generations to see what you have
sudo nixos-rebuild list-generations

# 2. Delete generations older than 30 days
sudo nix-collect-garbage --delete-older-than 30d

# 3. Also clean user profiles
nix-collect-garbage --delete-older-than 30d
home-manager expire-generations "-30 days"

# 4. Clean boot entries
sudo /run/current-system/bin/switch-to-configuration boot

# 5. Optimize the Nix store (deduplicates identical files)
nix-store --optimize
```

### Emergency Space Recovery

If you're critically low on space:

```bash
# 1. Keep only current generation
sudo nix-env --delete-generations old --profile /nix/var/nix/profiles/system
nix-env --delete-generations old

# 2. Aggressive garbage collection
sudo nix-collect-garbage -d

# 3. Clean boot entries
sudo /run/current-system/bin/switch-to-configuration boot

# 4. Optimize store
sudo nix-store --optimize
```

## Automated Cleanup

Your system is already configured with automatic garbage collection in the flake configuration. Check these settings in your system configuration:

```nix
# In hosts/_common/default.nix or similar
nix.gc = {
  automatic = true;
  dates = "weekly";
  options = "--delete-older-than 30d";
};

nix.settings.auto-optimise-store = true;
```

To modify the automatic cleanup schedule or retention period, edit the relevant configuration file and rebuild.

## Store Optimization (Hard Linking)

The Nix store often contains identical files across different packages. **Hard linking** allows multiple file paths to point to the same physical data on disk, saving significant space.

### What is Hard Linking?

When you have identical files in different packages (same libraries, docs, etc.), instead of storing each copy separately, Nix creates hard links - multiple directory entries pointing to the same inode (actual file data). The file takes up space only once but appears in multiple locations.

### Optimize the Store Manually

```bash
# Find and replace duplicate files with hard links
nix-store --optimize

# This can save many gigabytes - you'll see a message like:
# "note: currently hard linking saves 43180.64 MiB"
```

This command scans `/nix/store`, identifies identical files, and replaces duplicates with hard links. It's **safe to run anytime** and can save tens of gigabytes.

### Automatic Optimization

Your system is configured with automatic optimization (check your config):

```nix
nix.settings.auto-optimise-store = true;
```

This runs optimization automatically after each build. If you want to enable it:

```nix
# In hosts/_common/default.nix or your system config
nix.settings = {
  auto-optimise-store = true;  # Automatically hard-link after builds
};
```

### Check Optimization Savings

The savings are shown when you run garbage collection or optimization:

```bash
# Run garbage collection - shows hard link savings at the end
sudo nix-collect-garbage -d

# Output includes: "note: currently hard linking saves X MiB"
```

## Checking Disk Space Usage

```bash
# Check Nix store size
du -sh /nix/store

# Check total Nix directory size
du -sh /nix

# List largest store paths
nix path-info --all --size --human-readable | sort -k2 -h | tail -n 20

# Find what's keeping a specific store path alive
nix-store --query --roots /nix/store/some-hash-package

# Find all garbage (what would be deleted)
nix-store --gc --print-dead

# Check current hard link savings
nix-store --optimize  # Shows savings without needing to optimize
```

## Best Practices

1. **Keep at least 2-3 recent generations** - This allows rollback if the latest generation has issues
2. **Run cleanup monthly** - Or when you notice disk space getting low
3. **Test new generations before cleanup** - Make sure your system boots and works correctly
4. **Use automatic cleanup** - Configure `nix.gc.automatic` in your system config
5. **Monitor disk usage** - Keep an eye on `/nix/store` size
6. **Optimize the store** - Run `nix-store --optimize` periodically to deduplicate files

## Troubleshooting

### "Profile is in use" Error

If you get an error that a profile is in use:

```bash
# Ensure no other nix operations are running
# Then try again

# If persistent, you may need to reboot
```

### Boot Entries Not Removed

After garbage collection, always run:

```bash
sudo /run/current-system/bin/switch-to-configuration boot
```

This updates GRUB/systemd-boot to reflect the deleted generations.

### Can't Delete Current Generation

You cannot delete the currently active generation. To delete it, boot into another generation first, then delete the unwanted one.

## Additional Resources

- [NixOS Manual: Cleaning the Store](https://nixos.org/manual/nix/stable/package-management/garbage-collection.html)
- [Nix Store Optimization](https://nixos.org/manual/nix/stable/command-ref/nix-store/optimise.html)
