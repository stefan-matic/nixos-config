# Home Manager Operations Guide

A comprehensive guide to working with Home Manager in your NixOS dotfiles.

## Table of Contents

1. [Basic Commands](#basic-commands)
2. [Generations Management](#generations-management)
3. [Package Management](#package-management)
4. [Configuration Updates](#configuration-updates)
5. [Troubleshooting](#troubleshooting)
6. [Cleanup & Maintenance](#cleanup--maintenance)
7. [Advanced Operations](#advanced-operations)
8. [Quick Reference](#quick-reference)

---

## Basic Commands

### Building and Switching

```bash
# Apply your home-manager configuration (most common)
home-manager switch --flake ~/.dotfiles#stefanmatic@ZVIJER

# Build but don't activate (for testing)
home-manager build --flake ~/.dotfiles#stefanmatic@ZVIJER

# Apply without adding to boot menu (like nixos-rebuild test)
home-manager switch --flake ~/.dotfiles#stefanmatic@ZVIJER --no-out-link
```

### Flake-Specific Commands

```bash
# For specific user@host configuration
home-manager switch --flake ~/.dotfiles#stefanmatic@ZVIJER
home-manager switch --flake ~/.dotfiles#stefanmatic@t14
home-manager switch --flake ~/.dotfiles#stefanmatic@starlabs

# For user-only configuration (no host-specific configs)
home-manager switch --flake ~/.dotfiles#stefanmatic
```

### Checking Before Building

```bash
# Check for syntax errors without building
nix flake check ~/.dotfiles

# Show what would be built (dry-run)
home-manager build --flake ~/.dotfiles#stefanmatic@ZVIJER --dry-run
```

---

## Generations Management

Home Manager maintains generations just like NixOS, allowing you to rollback changes.

### Viewing Generations

```bash
# List all home-manager generations
home-manager generations

# Example output:
# 2024-12-29 19:45 : id 42 -> /nix/store/...-home-manager-generation
# 2024-12-29 18:30 : id 41 -> /nix/store/...-home-manager-generation
# 2024-12-29 16:20 : id 40 -> /nix/store/...-home-manager-generation
```

### Switching Between Generations

```bash
# Rollback to previous generation
home-manager switch --rollback

# Switch to a specific generation
home-manager switch --switch-generation 41

# Switch to generation by path
/nix/store/...-home-manager-generation/activate
```

### Finding Generation Details

```bash
# List generations with more detail
ls -l ~/.local/state/nix/profiles/

# See what packages are in a generation
nix-store -q --references ~/.local/state/nix/profiles/home-manager-41-link
```

---

## Package Management

### Adding Packages

**1. Add to organized module (recommended):**

```nix
# Edit appropriate file in user/packages/
# user/packages/development.nix
home.packages = with pkgs; [
  new-package
];
```

**2. Quick test (temporary):**

```bash
# Install package temporarily (not in config)
nix-shell -p package-name

# Or create a dev shell
nix develop nixpkgs#package-name
```

### Searching for Packages

```bash
# Search for packages
nix search nixpkgs package-name

# More detailed search
nix search nixpkgs --json package-name | jq

# Online search (faster)
# Visit: https://search.nixos.org/packages
```

### Removing Packages

```bash
# Remove from your config file, then:
home-manager switch --flake ~/.dotfiles#stefanmatic@ZVIJER

# Check for packages installed via nix-env (anti-pattern)
nix-env -q

# Remove packages installed via nix-env
nix-env -e package-name
```

### Updating Packages

```bash
# Update flake inputs (updates all packages)
cd ~/.dotfiles
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs

# Then rebuild
home-manager switch --flake ~/.dotfiles#stefanmatic@ZVIJER
```

---

## Configuration Updates

### Edit-Build-Test Workflow

```bash
# 1. Edit your configuration
vim ~/.dotfiles/user/packages/development.nix

# 2. Test syntax
nix flake check ~/.dotfiles

# 3. Build (without activating)
home-manager build --flake ~/.dotfiles#stefanmatic@ZVIJER

# 4. If build succeeds, activate
home-manager switch --flake ~/.dotfiles#stefanmatic@ZVIJER

# 5. If something breaks, rollback
home-manager switch --rollback
```

### Testing Changes Safely

```bash
# Build in a temporary directory
home-manager build --flake ~/.dotfiles#stefanmatic@ZVIJER --out-link /tmp/hm-test

# Inspect what would change
nix store diff-closures \
  ~/.local/state/nix/profiles/home-manager \
  /tmp/hm-test

# If happy with changes, apply
home-manager switch --flake ~/.dotfiles#stefanmatic@ZVIJER
```

---

## Troubleshooting

### Common Issues

#### Conflict Errors

```bash
# Error: "There is a conflict for the following files"
# Solution: Remove conflicting package installed via nix-env

nix-env -q                    # List packages
nix-env -e conflicting-pkg    # Remove it
home-manager switch --flake ~/.dotfiles#stefanmatic@ZVIJER
```

#### Build Failures

```bash
# Check for syntax errors
nix flake check ~/.dotfiles

# Build with verbose output
home-manager switch --flake ~/.dotfiles#stefanmatic@ZVIJER --show-trace

# Check logs
journalctl --user -u home-manager-stefanmatic.service
```

#### Path Issues

```bash
# Ensure home-manager is in PATH
echo $PATH | tr ':' '\n' | grep home-manager

# Reload shell configuration
source ~/.zshrc  # or ~/.bashrc

# Check profile location
ls -la ~/.nix-profile
```

#### Service Failures

```bash
# Check user services
systemctl --user status

# Restart a specific service
systemctl --user restart service-name

# View service logs
journalctl --user -u service-name -f
```

### Emergency Rollback

```bash
# Quick rollback to previous generation
home-manager switch --rollback

# If home-manager command is broken, manually activate
ls -l ~/.local/state/nix/profiles/
/nix/store/[previous-generation]/activate

# If everything is broken, use nix-env
nix-env --rollback
```

---

## Cleanup & Maintenance

### Removing Old Generations

```bash
# Remove generations older than 30 days
home-manager expire-generations "-30 days"

# Remove specific generations
home-manager remove-generations 40 41 42

# Keep only last 5 generations
home-manager generations | head -n 5 | tail -n +2 | cut -d' ' -f5 | xargs home-manager remove-generations

# Remove all but current
nix-env --delete-generations old --profile ~/.local/state/nix/profiles/home-manager
```

### Garbage Collection

```bash
# Remove unused packages (referenced by old generations)
nix-collect-garbage

# Remove old generations AND their packages
nix-collect-garbage -d

# More aggressive cleanup (removes all unreferenced packages)
nix-store --gc

# Check what would be deleted (dry-run)
nix-store --gc --print-dead
```

### Disk Space Management

```bash
# Check disk usage
du -sh /nix/store
du -sh ~/.local/share/nix

# See what's taking up space
nix path-info -rsSh ~/.nix-profile | sort -k2 -h

# Optimize store (deduplicate identical files)
nix-store --optimise

# Check how much space optimization saved
nix-store --optimise --verbose
```

---

## Advanced Operations

### Multiple Profiles

```bash
# Create a new profile
home-manager switch --flake ~/.dotfiles#stefanmatic@ZVIJER \
  --profile ~/profiles/work

# Switch between profiles
home-manager switch --flake ~/.dotfiles#stefanmatic@ZVIJER \
  --profile ~/profiles/personal
```

### Inspecting Configuration

```bash
# Show the flake configuration
nix flake show ~/.dotfiles

# Evaluate a specific option
home-manager option home.packages

# Show what packages would be installed
nix eval ~/.dotfiles#homeConfigurations.stefanmatic@ZVIJER.config.home.packages
```

### Building for Remote Systems

```bash
# Build for a different architecture
home-manager build --flake ~/.dotfiles#stefanmatic@t14 \
  --system x86_64-linux

# Build and copy to remote system
home-manager switch --flake ~/.dotfiles#stefanmatic@t14 \
  --build-host localhost --target-host t14
```

### Comparing Configurations

```bash
# Compare current vs. new build
nix store diff-closures \
  ~/.local/state/nix/profiles/home-manager \
  ~/.local/state/nix/profiles/home-manager-*-link

# List package differences between generations
nix-store -q --references ~/.local/state/nix/profiles/home-manager-41-link | sort > old.txt
nix-store -q --references ~/.local/state/nix/profiles/home-manager-42-link | sort > new.txt
diff old.txt new.txt
```

---

## Quick Reference

### Daily Operations

```bash
# Apply changes after editing config
home-manager switch --flake ~/.dotfiles#stefanmatic@ZVIJER

# View generations
home-manager generations

# Rollback
home-manager switch --rollback
```

### Weekly Maintenance

```bash
# Update packages
cd ~/.dotfiles && nix flake update

# Apply updates
home-manager switch --flake ~/.dotfiles#stefanmatic@ZVIJER

# Clean old generations (keep last 7 days)
home-manager expire-generations "-7 days"

# Garbage collect
nix-collect-garbage -d
```

### Monthly Cleanup

```bash
# Deep clean
home-manager expire-generations "-30 days"
nix-collect-garbage -d
nix-store --optimise

# Check disk usage
du -sh /nix/store
```

---

## Home Manager vs NixOS Commands

| Operation        | NixOS                                                                    | Home Manager                                 |
| ---------------- | ------------------------------------------------------------------------ | -------------------------------------------- |
| Apply config     | `sudo nixos-rebuild switch`                                              | `home-manager switch`                        |
| List generations | `sudo nix-env --list-generations --profile /nix/var/nix/profiles/system` | `home-manager generations`                   |
| Rollback         | `sudo nixos-rebuild switch --rollback`                                   | `home-manager switch --rollback`             |
| Garbage collect  | `sudo nix-collect-garbage -d`                                            | `nix-collect-garbage -d`                     |
| Update packages  | `sudo nixos-rebuild switch --upgrade`                                    | `nix flake update && home-manager switch`    |
| Remove old gens  | `sudo nix-env --delete-generations old`                                  | `home-manager expire-generations "-30 days"` |

---

## Tips & Best Practices

### 1. Always Test Before Committing

```bash
# Build first, then switch
home-manager build --flake ~/.dotfiles#stefanmatic@ZVIJER
home-manager switch --flake ~/.dotfiles#stefanmatic@ZVIJER
```

### 2. Keep Recent Generations

```bash
# Don't remove last few generations too quickly
# Keep at least 3-5 recent ones for safety
home-manager generations | head -n 6
```

### 3. Use Organized Package Modules

```nix
# Good: Organized by category
imports = [
  ../user/packages/development.nix
  ../user/packages/communication.nix
];

# Bad: Everything in one file
home.packages = [ package1 package2 ... package100 ];
```

### 4. Regular Maintenance Schedule

- **Daily**: Apply config changes, test
- **Weekly**: Update flake, clean generations > 7 days
- **Monthly**: Deep cleanup, optimize store

### 5. Document Custom Packages

```nix
home.packages = with pkgs; [
  # Cloud tools
  kubectl  # Kubernetes CLI
  awscli2  # AWS CLI

  # Development
  nodejs   # Required for project X
];
```

### 6. Use Git for Configuration History

```bash
# Before major changes
git commit -am "Save working config"

# If something breaks
git revert HEAD
home-manager switch --flake ~/.dotfiles#stefanmatic@ZVIJER
```

---

## Environment Variables

Home Manager sets several useful environment variables:

```bash
# Check home-manager variables
env | grep -i home

# Useful ones:
$HOME                    # Your home directory
$USER                    # Your username
$XDG_CONFIG_HOME         # ~/.config
$XDG_DATA_HOME          # ~/.local/share
$NIX_PATH               # Nix search path
```

---

## Getting Help

```bash
# Home manager help
home-manager --help

# Nix flake help
nix flake --help

# NixOS manual
man home-configuration.nix

# Online resources
# - https://nix-community.github.io/home-manager/
# - https://nixos.wiki/wiki/Home_Manager
# - https://discourse.nixos.org/
```

---

## Common Aliases (Add to Shell Config)

```bash
# Add to ~/.zshrc or ~/.bashrc
alias hm='home-manager'
alias hms='home-manager switch --flake ~/.dotfiles#stefanmatic@ZVIJER'
alias hmg='home-manager generations'
alias hmr='home-manager switch --rollback'
alias hmb='home-manager build --flake ~/.dotfiles#stefanmatic@ZVIJER'

# Cleanup aliases
alias hmc='home-manager expire-generations "-7 days" && nix-collect-garbage -d'
alias hmcc='home-manager expire-generations "-30 days" && nix-collect-garbage -d && nix-store --optimise'

# Update alias
alias hmu='cd ~/.dotfiles && nix flake update && home-manager switch --flake ~/.dotfiles#stefanmatic@ZVIJER'
```

---

## Your Flake Structure

Based on your `~/.dotfiles` setup:

```bash
# ZVIJER (desktop) - with all packages
home-manager switch --flake ~/.dotfiles#stefanmatic@ZVIJER

# T14 (laptop) - with laptop-specific Niri config
home-manager switch --flake ~/.dotfiles#stefanmatic@t14

# StarLabs (laptop) - with laptop-specific Niri config
home-manager switch --flake ~/.dotfiles#stefanmatic@starlabs

# Generic (no host-specific configs)
home-manager switch --flake ~/.dotfiles#stefanmatic
```

---

## Troubleshooting Checklist

When things go wrong, try these in order:

1. ✅ **Check syntax**: `nix flake check ~/.dotfiles`
2. ✅ **View errors**: `home-manager switch ... --show-trace`
3. ✅ **Check conflicts**: `nix-env -q`
4. ✅ **Rollback**: `home-manager switch --rollback`
5. ✅ **Check git**: `git status`, `git diff`
6. ✅ **Clean state**: `nix-collect-garbage -d`
7. ✅ **Verify paths**: `echo $PATH`
8. ✅ **Restart shell**: `exec $SHELL`

If all else fails:

- Check `docs/REFACTOR-SUMMARY.md` for package organization
- Check `docs/nixos-vs-home-manager-guide.md` for where packages should go
- Ask in NixOS Discourse or check GitHub issues
