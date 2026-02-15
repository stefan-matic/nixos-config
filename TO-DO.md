## TO-DO

- Test nix-on-droid from this common repo

- Revisit tailscale and drop cf tunnels

- add syncthing user password via agenix

### Agenix Secrets Management

- `secrets.nix` (repo root) - defines which keys can decrypt which secrets
- `secrets/wifi-routercheech.age` - encrypted WiFi password for router
- RouterCheech config updated to use `wpaPasswordFile` instead of plain text

To add host keys for full deployment:

1. Get SSH host key from each machine: `cat /etc/ssh/ssh_host_ed25519_key.pub`
2. Add to `secrets.nix` under the appropriate variable
3. Re-encrypt secrets: `agenix -r` (from repo root)
