# Raspberry Pi NixOS Configurations

This directory contains NixOS configurations for various Raspberry Pi projects. All configurations are based on the common `rpi4.nix` template located in `hosts/_common/`.

## Available Configurations

- **`magic-mirror/`** - Smart mirror display with auto-starting web interface
- **`arcade/`** - Retro gaming arcade machine with RetroArch
- **`routercheech/`** - Router/gateway with WiFi access point and DHCP/DNS services

## Building and Deployment

### The Remote Build Approach (Recommended)

**Important:** Raspberry Pis have limited CPU and memory resources. Building NixOS configurations directly on the Pi often leads to system hangs, out-of-memory errors, and very slow build times.

**Solution:** Build the system closure on a more powerful machine (your main computer) and deploy it remotely to the Pi.

#### Benefits of Remote Building

1. **Faster builds** - Leverage your desktop/laptop's CPU and memory
2. **No system hangs** - Avoid Pi freezing during resource-intensive builds
3. **Reliable deployment** - Consistent builds without Pi resource constraints
4. **Cross-compilation** - Build ARM64 packages on x86_64 systems

#### Remote Build Commands

```bash
# Build and deploy to a Pi over the network
nixos-rebuild switch --flake ~/.dotfiles#magic-mirror --target-host magic-mirror --use-remote-sudo

# For other configurations
nixos-rebuild switch --flake ~/.dotfiles#arcade --target-host arcade --use-remote-sudo
nixos-rebuild switch --flake ~/.dotfiles#routercheech --target-host routercheech --use-remote-sudo
```

#### Prerequisites for Remote Building

1. **SSH access** to the Pi with your user having sudo privileges
2. **SSH keys** configured for passwordless authentication
3. **Nix with flakes** enabled on both machines
4. **Network connectivity** between build machine and Pi

#### SSH Setup for Remote Builds

```bash
# Copy your SSH key to the Pi (run from your main machine)
ssh-copy-id stefanmatic@<pi-ip-address>

# Test passwordless SSH access
ssh stefanmatic@<pi-ip-address>

# Test sudo access (should not prompt for password)
ssh stefanmatic@<pi-ip-address> 'sudo whoami'
```

## SD Card Image Building

For initial installation, you can build SD card images on your main machine instead of using the NixOS installer.

### Adding SD Image Support

Add this to any Pi configuration to enable SD image building:

```nix
# In configuration.nix, add these imports
imports = [
  # ... existing imports ...
  "${nixpkgs}/nixos/modules/installer/sd-card/sd-image.nix"
  "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
];

# Disable modules that aren't needed for SD images
disabledModules = [
  "profiles/all-hardware.nix"
  "profiles/base.nix"
];
```

### Building SD Images

Add to your `flake.nix`:

```nix
# In flake.nix outputs
packages.x86_64-linux = {
  magic-mirror-sd = nixosConfigurations.magic-mirror.config.system.build.sdImage;
  arcade-sd = nixosConfigurations.arcade.config.system.build.sdImage;
  routercheech-sd = nixosConfigurations.routercheech.config.system.build.sdImage;
};
```

Build the SD image:

```bash
# Build SD card image
nix build .#magic-mirror-sd

# Result will be in ./result/sd-image/
# Flash to SD card with dd, balenaEtcher, or similar tool
sudo dd if=./result/sd-image/nixos-sd-image-*-aarch64-linux.img of=/dev/sdX bs=4M status=progress
```

## Hardware Support

### Raspberry Pi 4

Uses `nixos-hardware.nixosModules.raspberry-pi-4` with:

- **FKMS 3D acceleration** - `hardware.raspberry-pi."4".fkms-3d.enable = true`
- **Device tree overlays** - `hardware.raspberry-pi."4".apply-overlays-dtmerge.enable = true`
- **Optimized kernel** - `linux_rpi4` kernel package
- **GPU memory split** - 256MB allocated for graphics

### Raspberry Pi Zero 2W (Planned)

Support for Pi Zero 2W will use similar configuration with adjustments for:

- Lower memory constraints
- Different GPU configuration
- Optimized package selection for limited resources

## Common Configuration Features

All Pi configurations include:

### Performance Optimizations

- **zRAM swap** - 25% of memory for compressed swap
- **tmpfs /var/log** - Reduce SD card writes
- **noatime mounts** - Minimize SD card access
- **Journal size limits** - Prevent log growth

### SD Card Longevity

- **Reduced logging** - SystemMaxUse=50-100M
- **tmpfs for temporary files** - `/tmp` in memory
- **Optimized filesystem** - ext4 with noatime

### Remote Access

- **SSH enabled** by default with key-based auth
- **Firewall configured** - Only necessary ports open
- **User management** - Non-root user with sudo access

## Network Configuration

### WiFi Setup

Most configurations include WiFi support. Update these settings:

```nix
# In configuration.nix
networking.wireless = {
  enable = true;
  networks = {
    "YourWiFiName" = {
      psk = "your-wifi-password";
    };
  };
};
```

### Static IP (Optional)

For servers like `routercheech`:

```nix
networking.interfaces.wlan0.ipv4.addresses = [{
  address = "192.168.1.100";
  prefixLength = 24;
}];
```

## Troubleshooting

### Build Issues

- **Out of memory** → Use remote building with `--target-host`
- **Slow builds** → Use remote building or increase swap
- **Kernel panics** → Check power supply (5V 3A+ recommended)

### Boot Issues

- **Won't boot** → Check SD card, try different card
- **Hangs at boot** → Check hardware-configuration.nix
- **No network** → Verify WiFi credentials and country code

### Performance Issues

- **Slow response** → Check zRAM swap configuration
- **High load** → Monitor with `htop`, reduce running services
- **Storage full** → Check journal size, clean up old generations

## Development Workflow

1. **Make changes** on your development machine
2. **Test build** locally: `nix build .#magic-mirror`
3. **Deploy remotely**: `nixos-rebuild switch --flake ~/.dotfiles#magic-mirror --target-host magic-mirror --use-remote-sudo`
4. **Monitor deployment** via SSH to ensure services start correctly

## Configuration Updates

```bash
# Update flake inputs (nixpkgs, etc.)
nix flake update

# Rebuild and deploy
nixos-rebuild switch --flake ~/.dotfiles#magic-mirror --target-host magic-mirror --use-remote-sudo

# Check system status
ssh magic-mirror 'systemctl status'
```

## Security Considerations

- **Change default passwords** in configurations
- **Use SSH keys** instead of passwords
- **Update regularly** with `nix flake update`
- **Monitor services** for unexpected behavior
- **Firewall rules** - Only open necessary ports

## Resources

- [NixOS on Pi 4 Guide](https://mtlynch.io/nixos-pi4/) - Comprehensive setup guide
- [nixos-hardware](https://github.com/NixOS/nixos-hardware) - Hardware-specific configurations
- [Pi Zero 2W Reference](https://github.com/plmercereau/nixos-pi-zero-2) - Pi Zero 2W specific setup
