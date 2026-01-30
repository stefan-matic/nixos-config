# WireGuard with NetworkManager Setup Guide

This guide explains how to set up WireGuard VPN connections with NetworkManager for use with the DMS VPN widget.

## System Configuration

### 1. Enable WireGuard Support in NixOS

WireGuard support is configured in `hosts/_common/default.nix` for all hosts:

```nix
networking = {
  hostName = config.systemSettings.hostname;
  networkmanager.enable = true;
  # WireGuard support
  wireguard.enable = true;
};
```

### 2. Install WireGuard Tools

The `wireguard-tools` package is installed for all client systems in `hosts/_common/client.nix`:

```nix
environment.systemPackages = with pkgs; [
  # VPN tools
  wireguard-tools  # WireGuard VPN support for NetworkManager
];
```

### 3. Apply Configuration

Rebuild your system to apply these changes:

```bash
sudo nixos-rebuild switch --flake ~/.dotfiles#stefan-t14
```

## Creating a WireGuard Connection

NetworkManager's `nmcli import` command doesn't work reliably with WireGuard `.conf` files. Instead, create a NetworkManager connection file manually.

### Step 1: Parse Your WireGuard Config

Given a standard WireGuard config file like:

```ini
[Interface]
PrivateKey = qG7BrTtLOSUGkri89YrpDpSRTS+h8+jC7swoVXvypXU=
Address = 10.100.90.3/32
DNS = 10.100.90.1

[Peer]
PublicKey = urbxEvSQEesu/7x85V624LqP0591vQkMmeTw2D5jXiE=
AllowedIPs = 0.0.0.0/0
Endpoint = vpn.matic.ba:51821
```

Extract these values:

- **PrivateKey**: Your private key
- **Address**: Your VPN IP address (with CIDR notation)
- **DNS**: DNS server IP
- **PublicKey**: Server's public key
- **AllowedIPs**: Traffic to route through VPN (0.0.0.0/0 = all traffic)
- **Endpoint**: Server address and port

### Step 2: Create NetworkManager Connection File

Create a file `/tmp/YourVPN.nmconnection` with this structure:

```ini
[connection]
id=YourVPN
uuid=GENERATE-NEW-UUID-HERE
type=wireguard
autoconnect=false
interface-name=wg0

[wireguard]
private-key=YOUR_PRIVATE_KEY_HERE
private-key-flags=0

[wireguard-peer.SERVER_PUBLIC_KEY_HERE]
endpoint=SERVER_ADDRESS:PORT
allowed-ips=0.0.0.0/0;
persistent-keepalive=25

[ipv4]
address1=YOUR_VPN_IP/32
dns=DNS_SERVER_IP;
ignore-auto-dns=true
method=manual

[ipv6]
addr-gen-mode=default
method=disabled

[proxy]
```

**Important notes:**

- `uuid`: Generate a new UUID with `uuidgen` or use any UUID generator
- `id`: Connection name (shows up in NetworkManager and DMS widget)
- `interface-name`: Usually `wg0` for the first WireGuard connection
- `[wireguard-peer.PUBLICKEY]`: Section name includes the peer's public key
- `persistent-keepalive=25`: Keeps connection alive through NAT (optional)
- `allowed-ips=0.0.0.0/0;`: Note the semicolon at the end
- `dns=10.100.90.1;`: Note the semicolon at the end

### Step 3: Install the Connection

```bash
# Copy to NetworkManager's system directory
sudo cp /tmp/YourVPN.nmconnection /etc/NetworkManager/system-connections/YourVPN.nmconnection

# Set correct permissions (required for security)
sudo chmod 600 /etc/NetworkManager/system-connections/YourVPN.nmconnection
sudo chown root:root /etc/NetworkManager/system-connections/YourVPN.nmconnection

# Reload NetworkManager to recognize the new connection
sudo nmcli connection reload
```

### Step 4: Verify and Connect

```bash
# List all connections (your VPN should appear)
nmcli connection show

# Connect to VPN
nmcli connection up YourVPN

# Check connection status
nmcli connection show --active

# Disconnect
nmcli connection down YourVPN
```

## Using with DMS VPN Widget

Once the connection is installed:

1. The DMS VPN widget should automatically detect the WireGuard connection
2. Click the VPN widget to see available VPN connections
3. Toggle your WireGuard connection on/off directly from the widget

No additional configuration is needed - the widget uses NetworkManager's D-Bus interface to manage connections.

## Example: Complete Connection File

Here's a real example (with sanitized keys):

```ini
[connection]
id=Unifi-VPN
uuid=a1b2c3d4-e5f6-7890-abcd-ef1234567890
type=wireguard
autoconnect=false
interface-name=wg0

[wireguard]
private-key=qG7BrTtLOSUGkri89YrpDpSRTS+h8+jC7swoVXvypXU=
private-key-flags=0

[wireguard-peer.urbxEvSQEesu/7x85V624LqP0591vQkMmeTw2D5jXiE=]
endpoint=vpn.matic.ba:51821
allowed-ips=0.0.0.0/0;
persistent-keepalive=25

[ipv4]
address1=10.100.90.3/32
dns=10.100.90.1;
ignore-auto-dns=true
method=manual

[ipv6]
addr-gen-mode=default
method=disabled

[proxy]
```

## Troubleshooting

### Connection doesn't appear in DMS widget

```bash
# Reload NetworkManager
sudo nmcli connection reload

# Check if connection exists
nmcli connection show

# Restart NetworkManager (last resort)
sudo systemctl restart NetworkManager
```

### Connection fails to activate

```bash
# Check detailed connection status
nmcli connection show YourVPN

# View NetworkManager logs
journalctl -u NetworkManager -f

# Test WireGuard directly
sudo wg show
```

### Permission errors

Connection files in `/etc/NetworkManager/system-connections/` must have:

- Owner: `root:root`
- Permissions: `600` (read/write for owner only)

```bash
sudo chmod 600 /etc/NetworkManager/system-connections/*.nmconnection
sudo chown root:root /etc/NetworkManager/system-connections/*.nmconnection
```

## Multiple WireGuard Connections

To add multiple WireGuard VPNs:

1. Use different `interface-name` values: `wg0`, `wg1`, `wg2`, etc.
2. Each connection needs a unique `uuid`
3. Each connection needs a unique `id` (display name)

Example:

```ini
# First VPN
interface-name=wg0

# Second VPN
interface-name=wg1
```

## Security Notes

- **Never commit connection files to git** - they contain private keys
- Connection files are stored in `/etc/NetworkManager/system-connections/`
- Private keys are stored in plaintext but protected by file permissions
- For production, consider using `private-key-flags=4` with an external keyring

## References

- [WireGuard Official Documentation](https://www.wireguard.com/)
- [NetworkManager WireGuard Support](https://networkmanager.dev/docs/api/latest/settings-wireguard.html)
- [nmcli Examples](https://networkmanager.dev/docs/api/latest/nmcli-examples.html)
