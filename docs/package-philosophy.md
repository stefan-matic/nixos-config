# Package Philosophy

**System manages infrastructure, Home Manager manages user applications.**

## Decision Framework

### System Packages (`system/packages/`, `hosts/`)

Use for:

- Hardware tools (lm_sensors, pciutils, brightnessctl)
- System monitoring (htop, iotop, strace)
- Multi-user tools (git, vim)
- System services (docker, bluetooth)
- Desktop infrastructure (Wayland tools, file managers)

### User Packages (`user/packages/`)

Use for:

- Personal applications (browsers, IDEs, communication)
- Development tools (kubectl, terraform, cloud CLIs)
- Productivity software (LibreOffice, notes)
- Media players, games
- Anything that runs without root

## Quick Test

1. **Multiple users need it?** → System
2. **Requires root access?** → System
3. **Hardware-related?** → System
4. **Personal preference?** → Home Manager
5. **Can run as user?** → Home Manager

## Package Locations

```
system/packages/
├── common.nix      # git, vim, wget, compression
├── hardware.nix    # sensors, pciutils, brightnessctl
├── monitoring.nix  # htop, iotop, strace
└── desktop.nix     # Wayland tools, file managers

user/packages/
├── common.nix       # browsers, terminals, media
├── development.nix  # IDEs, DevOps, cloud CLIs
├── communication.nix # Slack, Discord, Zoom
├── creative.nix     # video editing, 3D
├── gaming.nix       # Lutris, Wine, Vulkan
└── productivity.nix # notes, VPN, utilities

hosts/{hostname}/packages.nix  # Host-specific hardware
```

## Adding Packages

**User app:**

```nix
# user/packages/development.nix
home.packages = with pkgs; [ new-tool ];
```

**System tool:**

```nix
# system/packages/monitoring.nix
environment.systemPackages = with pkgs; [ new-monitor ];
```

**Host-specific:**

```nix
# hosts/zvijer/packages.nix
environment.systemPackages = with pkgs; [ razer-tool ];
```
