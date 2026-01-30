# Server Deployment Guide

Single-command deployment from clients to remote servers.

## Quick Deploy

```bash
nixos-rebuild switch \
  --flake ~/.dotfiles#dell-micro-3050 \
  --target-host stefanmatic@dell-micro-3050 \
  --sudo \
  --ask-sudo-password
```

## New Server Setup

### 1. SSH Config (~/.ssh/config) - Required

```
Host dell-micro-3050
    HostName 10.100.x.x
    User stefanmatic
```

### 2. Copy SSH Key

```bash
ssh-copy-id dell-micro-3050
```

### 3. Add Trusted User (on server)

SSH in and edit `/etc/nixos/configuration.nix`:

```nix
nix.settings.trusted-users = [ "root" "stefanmatic" ];
```

Then rebuild locally:

```bash
sudo nixos-rebuild switch
```

### 4. Create Host Config

```bash
mkdir -p ~/.dotfiles/hosts/new-server
ssh new-server "sudo nixos-generate-config --show-hardware-config" \
  > ~/.dotfiles/hosts/new-server/hardware-configuration.nix
```

Copy `env.nix` and `configuration.nix` from another server host, update hostname/username.

### 5. Add to flake.nix

```nix
new-server = nixpkgs.lib.nixosSystem {
  specialArgs = { inherit inputs outputs; };
  modules = [ ./hosts/new-server/configuration.nix ];
};
```

### 6. Stage and Deploy

```bash
git add hosts/new-server/
nixos-rebuild switch \
  --flake ~/.dotfiles#new-server \
  --target-host user@new-server \
  --sudo \
  --ask-sudo-password
```

## After First Deploy

- `sysmatic` user created with SSH key
- Future deploys: use `sysmatic@host`
- Home-manager config included automatically

## Hosts

| Host            | Command                                                                                                                         |
| --------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| dell-micro-3050 | `nixos-rebuild switch --flake ~/.dotfiles#dell-micro-3050 --target-host stefanmatic@dell-micro-3050 --sudo --ask-sudo-password` |
| z420            | `nixos-rebuild switch --flake ~/.dotfiles#z420 --target-host sysmatic@z420 --sudo --ask-sudo-password`                          |
