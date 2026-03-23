# OpenVPN Setup with NetworkManager

Guide for configuring an OpenVPN connection on NixOS hosts with NetworkManager, handling routing and DNS conflicts.

## Problem

OpenVPN servers often push configuration that causes issues:

1. **Internet loss**: The server pushes a default route through the tunnel (metric 50), overriding your local default route (metric 100). All traffic goes through the VPN which may not forward to the internet.
2. **DNS failure**: With split-tunnel, the VPN DNS server is needed to resolve internal hostnames but systemd-resolved may not route queries to it.
3. **Local LAN conflict**: The server may push a broad route (e.g. `10.100.0.0/16`) through the tunnel that overlaps with your local network.

## Setup Steps

### 1. Import the .ovpn profile

```bash
nmcli connection import type openvpn file "/path/to/profile.ovpn"
```

### 2. Rename the connection (optional)

```bash
nmcli connection modify "<imported-name>" connection.id "<short-name>"
```

### 3. Enable split-tunnel (prevent VPN from becoming the default gateway)

Without this, all traffic goes through the tunnel and internet breaks:

```bash
nmcli connection modify "<connection-name>" ipv4.never-default yes ipv6.never-default yes
```

This keeps the specific subnet routes the VPN pushes while leaving internet traffic on the local interface. Equivalent to "Use this connection only for resources on its network" in the GUI.

### 4. Configure DNS to route through the VPN

The VPN pushes a DNS server for resolving internal hostnames. Without this step, systemd-resolved won't use it and internal names won't resolve.

```bash
nmcli connection modify "<connection-name>" \
  ipv4.dns-search "~." \
  ipv6.dns-search "~." \
  ipv4.dns-priority -50 \
  ipv6.dns-priority -50
```

- `~.` tells systemd-resolved to route all DNS queries through the VPN DNS server
- `-50` priority ensures the VPN DNS takes precedence over local DNS

### 5. Remove conflicting LAN routes (if applicable)

If the VPN pushes a route that overlaps with your local network, it needs to be removed after the tunnel comes up.

**NixOS (automatic):** The dispatcher script in `hosts/_common/default.nix` handles this. After `sudo nixos-rebuild switch`, it runs automatically on VPN connect.

**Manual / non-NixOS:** Run after connecting:

```bash
# Replace with whatever subnet conflicts with your LAN
sudo ip route del <conflicting-subnet> dev tun0
```

## Complete Example

```bash
# Import
nmcli connection import type openvpn file "/path/to/profile.ovpn"

# Rename
nmcli connection modify "<imported-name>" connection.id "my-vpn"

# Split-tunnel
nmcli connection modify "my-vpn" ipv4.never-default yes ipv6.never-default yes

# DNS routing
nmcli connection modify "my-vpn" \
  ipv4.dns-search "~." ipv6.dns-search "~." \
  ipv4.dns-priority -50 ipv6.dns-priority -50

# Connect
nmcli connection up "my-vpn"
```

## Verification

After connecting:

```bash
# Verify internet works
curl -s -o /dev/null -w "%{http_code}" https://google.com

# Verify local LAN works
ping -c1 <local-gateway>

# Verify VPN resources work (by hostname)
ping -c1 <vpn-host>

# Verify DNS is routed through VPN
# Should show DNS Domain: ~. and DNS Server: 100.96.x.x on tun0
resolvectl status tun0

# Check routes - no default route via tun0, no conflicting LAN route
ip route show | grep tun0

# Verify no default route through tunnel
ip route show default
# Should only show: default via <local-gateway> dev <interface>
```

## Troubleshooting

### VPN disconnects after ~10-25 seconds

Check NM logs with verbose logging:

```bash
sudo nmcli general logging level INFO domains VPN,DEVICE,CORE,CONCHECK
nmcli connection up "<connection-name>"
# After disconnect:
journalctl -u NetworkManager --since "2 min ago" --no-pager | grep -v "nm-openvpn"
```

If you see `policy: set '<connection>' (tun0) as default for IPv4 routing and DNS`, the `never-default` setting wasn't applied. Re-run step 3.

### DNS not resolving VPN hostnames

Verify DNS config on the tunnel interface:

```bash
resolvectl status tun0
```

Should show:
- `DNS Servers: 100.96.x.x` (or similar VPN DNS)
- `DNS Domain: ~.`

If `DNS Domain` is missing, re-run step 4. If `tun0` doesn't exist, check if OpenVPN recreated it as `tun1` (`ip link show | grep tun`).

### "Network is unreachable" in OpenVPN logs

`sitnl_send: rtnl: generic error (-101): Network is unreachable` during connection is a known warning from the server pushing options that don't apply on Linux (`block-outside-dns`, `client-ip`). It does not prevent the connection from working.

## Related Files

- NM dispatcher script: `hosts/_common/default.nix` (networking.networkmanager.dispatcherScripts)
- Firewall: `system/security/firewall.nix` (`checkReversePath = "loose"`)
