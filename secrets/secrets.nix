# Agenix secrets configuration
# Defines which SSH keys can decrypt which secrets
#
# IMPORTANT: After adding a new host, you need to:
# 1. Get the host's SSH ed25519 public key: ssh-keyscan -t ed25519 <hostname> 2>/dev/null | cut -d' ' -f2-
#    Or from the host: cat /etc/ssh/ssh_host_ed25519_key.pub
# 2. Add it to the appropriate variable below
# 3. Re-encrypt any secrets that host needs: agenix -r

let
  # User SSH keys - for encrypting/decrypting with agenix CLI
  stefanmatic = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDJ2jVUL/jANIzKv14MfJN6bNQzYD41BJssTZiDL34sk stefan@matic.ba";

  users = [ stefanmatic ];

  # Host SSH keys - each host needs its public key here to decrypt secrets
  # Get with: cat /etc/ssh/ssh_host_ed25519_key.pub
  # Or remotely: ssh-keyscan -t ed25519 <hostname> 2>/dev/null | cut -d' ' -f2-

  # TODO: Add actual host keys after getting them from each machine
  # Example format:
  # zvijer = "ssh-ed25519 AAAAC3... root@ZVIJER";
  # t14 = "ssh-ed25519 AAAAC3... root@stefan-t14";
  # starlabs = "ssh-ed25519 AAAAC3... root@starlabs";
  # z420 = "ssh-ed25519 AAAAC3... root@z420";
  # routercheech = "ssh-ed25519 AAAAC3... root@routercheech";

  # For now, only user key - host keys should be added
  allHosts = [ ];

  # Raspberry Pi hosts that need router secrets
  rpiHosts = [ ];

in
{
  # WiFi password for RouterCheech AP
  # Only the router RPI needs this, plus user for CLI access
  "wifi-routercheech.age".publicKeys = users ++ rpiHosts;

  # Note: Syncthing device IDs are public identifiers (like public key fingerprints)
  # and not suitable for agenix - they're required at NixOS build time as strings.
  # They're low-risk to expose anyway (can't be used without mutual authentication).
}
