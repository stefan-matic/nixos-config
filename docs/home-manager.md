# Home Manager Guide

Manage user environment and dotfiles.

## Apply Configuration

```bash
# Host-specific (includes Niri config)
home-manager switch --flake ~/.dotfiles#stefanmatic@ZVIJER
home-manager switch --flake ~/.dotfiles#stefanmatic@t14
home-manager switch --flake ~/.dotfiles#stefanmatic@starlabs

# Generic (no host-specific configs)
home-manager switch --flake ~/.dotfiles#stefanmatic
```

## Generations

```bash
# List
home-manager generations

# Rollback
home-manager switch --rollback

# Switch to specific
home-manager switch --switch-generation 41

# Clean old (30+ days)
home-manager expire-generations "-30 days"
```

## Adding Packages

Add to appropriate file in `user/packages/`:

```nix
# user/packages/development.nix
home.packages = with pkgs; [
  new-package
];
```

Then apply: `home-manager switch --flake ~/.dotfiles#stefanmatic@ZVIJER`

## Testing Changes

```bash
# Build without activating
home-manager build --flake ~/.dotfiles#stefanmatic@ZVIJER

# Check syntax
nix flake check ~/.dotfiles
```

## Troubleshooting

```bash
# Conflict errors - remove nix-env packages
nix-env -q
nix-env -e conflicting-pkg

# View errors
home-manager switch ... --show-trace

# Service issues
systemctl --user status
journalctl --user -u service-name
```

## vs NixOS Commands

| Operation   | NixOS                             | Home Manager                     |
| ----------- | --------------------------------- | -------------------------------- |
| Apply       | `sudo nixos-rebuild switch`       | `home-manager switch`            |
| Rollback    | `nixos-rebuild switch --rollback` | `home-manager switch --rollback` |
| Generations | `nixos-rebuild list-generations`  | `home-manager generations`       |
