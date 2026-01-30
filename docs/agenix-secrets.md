# Agenix Secrets Management

This guide explains how to manage encrypted secrets in this NixOS configuration using agenix.

## Overview

Agenix encrypts secrets with SSH keys, allowing secrets to be stored safely in git while only being decryptable by authorized machines and users.

**Current secrets:**

- `wifi-routercheech.age` - WiFi password for RouterCheech AP

## Two Types of Keys (Important!)

Agenix uses two different types of SSH keys for different purposes:

### User Keys (for CLI operations)

Your personal SSH key (managed by KeePassXC, added to ssh-agent)

**Used for:**

- Running `agenix -e` to edit secrets
- Running `agenix -r` to re-encrypt secrets
- Any CLI operations with the agenix tool

**Works from any machine** where your key is in the SSH agent

### Host Keys (for boot-time decryption)

Each NixOS machine has a unique host SSH key at `/etc/ssh/ssh_host_ed25519_key`.

**Used for:**

- Decrypting secrets during NixOS boot
- Making secrets available to system services

**Why host keys are needed:**

- Your user isn't logged in during early boot
- SSH agent isn't running yet
- System services (like hostapd for WiFi) need secrets before any user logs in

## When Do You Need Host Keys?

| Scenario                              | User Key     | Host Key     |
| ------------------------------------- | ------------ | ------------ |
| Edit/create secrets with `agenix` CLI | Required     | Not needed   |
| System service needs secret at boot   | Not used     | Required     |
| User service needs secret after login | Either works | Either works |

**Examples:**

- WiFi password for RouterCheech → needs RouterCheech's host key (hostapd runs at boot)
- API key for a user script → user key is enough (runs after login)
- Database password for a system service → needs host key (service starts at boot)

## Directory Structure

```
secrets/
├── secrets.nix              # Defines which keys can decrypt which secrets
├── wifi-routercheech.age    # Encrypted WiFi password
└── (future secrets...)
```

## Current Setup

Your user key is already configured in `secrets/secrets.nix`:

```nix
let
  stefanmatic = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDJ2jVUL/jANIzKv14MfJN6bNQzYD41BJssTZiDL34sk stefan@matic.ba";
  users = [ stefanmatic ];
```

This means you can already:

- Edit any secret from any machine (as long as your key is in the agent)
- Create new secrets
- Re-encrypt secrets

## Adding Host Keys (When Needed)

Only add host keys when a machine needs to decrypt secrets at boot time.

### Step 1: Get the Host's SSH Public Key

On the machine that needs boot-time secret access:

```bash
cat /etc/ssh/ssh_host_ed25519_key.pub
```

Outputs something like:

```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA... root@hostname
```

### Step 2: Add to secrets.nix

```nix
let
  # User keys - for CLI operations
  stefanmatic = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDJ2jVUL/jANIzKv14MfJN6bNQzYD41BJssTZiDL34sk stefan@matic.ba";
  users = [ stefanmatic ];

  # Host keys - only for machines that need boot-time secrets
  routercheech = "ssh-ed25519 AAAAC3... root@routercheech";
  rpiHosts = [ routercheech ];

  # Desktop host keys - add only if they need boot-time secrets
  # zvijer = "ssh-ed25519 AAAAC3... root@ZVIJER";
  # t14 = "ssh-ed25519 AAAAC3... root@stefan-t14";
  # allHosts = [ zvijer t14 ];
in
{
  # WiFi secret - needs RPI host key (hostapd runs at boot)
  "wifi-routercheech.age".publicKeys = users ++ rpiHosts;

  # Example: secret only for CLI access (no host key needed)
  # "my-api-key.age".publicKeys = users;

  # Example: secret for desktop system service
  # "vpn-credentials.age".publicKeys = users ++ allHosts;
}
```

### Step 3: Re-encrypt Secrets

After modifying `secrets.nix`, re-encrypt so new keys can decrypt:

```bash
cd ~/.dotfiles/secrets
agenix -r
```

### Step 4: Rebuild

```bash
sudo nixos-rebuild switch --flake ~/.dotfiles#<hostname>
```

## Creating New Secrets

### Step 1: Decide Who Needs Access

- **CLI-only secret** (scripts, personal use): just add `users`
- **Boot-time secret** (system service): add `users` + relevant host keys

### Step 2: Define in secrets.nix

```nix
{
  # CLI-only - your user key can decrypt
  "my-api-key.age".publicKeys = users;

  # Boot-time - host also needs to decrypt
  "service-password.age".publicKeys = users ++ allHosts;
}
```

### Step 3: Create the Secret

```bash
cd ~/.dotfiles/secrets
agenix -e my-api-key.age
```

Your editor opens. Enter the secret, save, exit. Done.

### Step 4: Reference in NixOS Config

```nix
{
  age.secrets.my-api-key = {
    file = ../../secrets/my-api-key.age;
    owner = "root";
    group = "root";
    mode = "0400";
  };

  # Use it
  someService.passwordFile = config.age.secrets.my-api-key.path;
}
```

## Common Commands

```bash
# Edit a secret (uses your SSH agent key)
agenix -e <secret-name>.age

# Re-encrypt all secrets (after changing secrets.nix)
agenix -r

# Decrypt and print a secret (for testing)
agenix -d <secret-name>.age

# List all secrets
ls secrets/*.age
```

## Troubleshooting

### "No matching keys found" when running agenix

Your SSH key isn't in the agent. Either:

- Unlock KeePassXC and let it add the key
- Or manually: `ssh-add ~/.ssh/id_personal`

### Secret not decrypted at boot

The host key isn't in `secrets.nix` for that secret:

1. Get host key: `cat /etc/ssh/ssh_host_ed25519_key.pub`
2. Add to `secrets.nix`
3. Re-encrypt: `agenix -r`
4. Push and rebuild

### Checking if secrets are available

After boot, decrypted secrets are in `/run/agenix/`:

```bash
ls -la /run/agenix/
```

## Security Notes

- User keys are for convenience (CLI operations)
- Host keys are for security (machines can only decrypt their assigned secrets)
- Never commit unencrypted secrets
- `.age` files are safe to commit (encrypted)
- `secrets.nix` only has public keys (safe to commit)
- Decrypted secrets live in tmpfs (RAM only, not on disk)

## Quick Reference

| Task                         | Command                                 |
| ---------------------------- | --------------------------------------- |
| Edit secret                  | `agenix -e secret.age`                  |
| Re-encrypt after adding keys | `agenix -r`                             |
| View secret (test)           | `agenix -d secret.age`                  |
| Get host key                 | `cat /etc/ssh/ssh_host_ed25519_key.pub` |
| Check decrypted secrets      | `ls /run/agenix/`                       |
