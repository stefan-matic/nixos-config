# WireGuard VPN Setup

Configure WireGuard with NetworkManager for DMS widget.

## Prerequisites

Already configured in system:

- `networking.wireguard.enable = true`
- `wireguard-tools` package

## Create Connection

NetworkManager's `nmcli import` doesn't work reliably. Create manually:

### 1. Create Connection File

`/tmp/MyVPN.nmconnection`:

```ini
[connection]
id=MyVPN
uuid=GENERATE-WITH-uuidgen
type=wireguard
autoconnect=false
interface-name=wg0

[wireguard]
private-key=YOUR_PRIVATE_KEY
private-key-flags=0

[wireguard-peer.SERVER_PUBLIC_KEY]
endpoint=vpn.example.com:51820
allowed-ips=0.0.0.0/0;
persistent-keepalive=25

[ipv4]
address1=10.0.0.2/32
dns=10.0.0.1;
ignore-auto-dns=true
method=manual

[ipv6]
method=disabled

[proxy]
```

### 2. Install

```bash
sudo cp /tmp/MyVPN.nmconnection /etc/NetworkManager/system-connections/
sudo chmod 600 /etc/NetworkManager/system-connections/MyVPN.nmconnection
sudo chown root:root /etc/NetworkManager/system-connections/MyVPN.nmconnection
sudo nmcli connection reload
```

### 3. Connect

```bash
nmcli connection up MyVPN
nmcli connection down MyVPN
```

## DMS Widget

Connection appears automatically in DMS VPN widget after reload.

## Multiple VPNs

Use different `interface-name`: `wg0`, `wg1`, etc.

## Troubleshooting

```bash
# Connection doesn't appear
sudo nmcli connection reload

# Check status
nmcli connection show
sudo wg show

# View logs
journalctl -u NetworkManager -f
```

## Security

- Never commit connection files (contain private keys)
- Files stored in `/etc/NetworkManager/system-connections/`
- Protected by 600 permissions
