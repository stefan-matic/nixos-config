# NixOS System Configuration vs Home Manager: The Complete Guide

## Understanding the Separation

The key principle is: **NixOS manages the system, Home Manager manages the user environment.**

### **NixOS System Configuration** (`hosts/`)
- **What it affects**: The entire system, all users, system services
- **Requires**: `sudo nixos-rebuild switch` (root privileges)
- **Scope**: System-wide configuration

### **Home Manager Configuration** (`home/`)  
- **What it affects**: Individual user environment, dotfiles, user applications
- **Requires**: `home-manager switch` (user privileges)
- **Scope**: Per-user configuration

## The Golden Rules

### ✅ **NixOS System Config Should Handle:**

#### 1. **System Services & Daemons**
```nix
# In hosts/*/configuration.nix or system/
services = {
  openssh.enable = true;           # SSH daemon
  docker.enable = true;            # Docker daemon
  postgresql.enable = true;        # Database server
  nginx.enable = true;             # Web server
  bluetooth.enable = true;         # Bluetooth service
  printing.enable = true;          # CUPS printing
  avahi.enable = true;             # Network discovery
  syncthing.enable = true;         # System-wide sync (multi-user)
};
```

#### 2. **Hardware & Kernel Configuration**
```nix
# Hardware, drivers, kernel modules
hardware = {
  bluetooth.enable = true;
  nvidia.modesetting.enable = true;
  pulseaudio.enable = true;        # System audio
};

boot = {
  kernelModules = [ "kvm-intel" ];
  kernelParams = [ "quiet" "splash" ];
};
```

#### 3. **Network & Security**
```nix
# Network interfaces, firewalls, VPNs
networking = {
  firewall.allowedTCPPorts = [ 22 80 443 ];
  interfaces.eth0.ipv4.addresses = [...];
  wireless.enable = true;
  wireguard.enable = true;
};

security = {
  sudo.wheelNeedsPassword = false;
  pam.services.login.enableGnomeKeyring = true;
};
```

#### 4. **System-Wide Programs**
```nix
# Tools needed by system or multiple users
environment.systemPackages = with pkgs; [
  git                    # Often needed by system
  vim                    # Emergency editor
  htop                   # System monitoring
  docker-compose         # System container tools
  yubikey-personalization # Hardware tools
  usbutils               # Hardware utilities
];

programs = {
  gnupg.agent.enable = true;       # System-wide GPG
  ssh.startAgent = true;           # System SSH agent
  dconf.enable = true;             # System configuration database
};
```

#### 5. **Desktop Environment / Window Manager**
```nix
# Display managers, desktop environments
services = {
  xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };
  
  # OR for a window manager setup
  displayManager.sddm.enable = true;
};

# Window manager programs (system-wide)
programs.hyprland.enable = true;
```

#### 6. **User Account Management**
```nix
users.users.stefanmatic = {
  isNormalUser = true;
  extraGroups = [ "wheel" "docker" "audio" "video" ];
  shell = pkgs.zsh;              # Default shell
  openssh.authorizedKeys.keys = [...];
};
```

#### 7. **Font Installation (System-Wide)**
```nix
fonts.packages = with pkgs; [
  noto-fonts
  noto-fonts-cjk
  noto-fonts-emoji
  liberation_ttf
  (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
];
```

---

### ✅ **Home Manager Should Handle:**

#### 1. **Application Configuration & Dotfiles**
```nix
# User-specific app configs
programs = {
  git = {
    enable = true;
    userName = "Stefan Matic";
    userEmail = "stefan@matic.ba";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };
  
  zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "docker" ];
      theme = "agnoster";
    };
  };
  
  kitty = {
    enable = true;
    font.name = "JetBrains Mono";
    settings = {
      background_opacity = "0.9";
      font_size = 12;
    };
  };
};
```

#### 2. **User Applications & Packages**
```nix
home.packages = with pkgs; [
  # Development tools
  vscode
  discord
  slack
  
  # Media & productivity
  vlc
  firefox
  chromium
  libreoffice
  
  # CLI tools (user preference)
  ripgrep
  fd
  bat
  exa
  
  # Language-specific tools
  nodejs
  python3
  go
];
```

#### 3. **User Services**
```nix
services = {
  # User-level services
  kdeconnect = {
    enable = true;
    indicator = true;
  };
  
  syncthing.enable = true;         # Personal file sync
  mpris-proxy.enable = true;       # Media keys
  
  # Custom user services
  deej-new.enable = true;          # Volume control
};
```

#### 4. **XDG Directories & User Environment**
```nix
xdg = {
  enable = true;
  userDirs = {
    enable = true;
    createDirectories = true;
    desktop = "${config.home.homeDirectory}/Desktop";
    documents = "${config.home.homeDirectory}/Documents";
    download = "${config.home.homeDirectory}/Downloads";
    music = "${config.home.homeDirectory}/Music";
  };
  
  configFile = {
    "some-app/config.yml".text = ''
      key: value
    '';
  };
};

home.file = {
  ".bashrc".text = "export EDITOR=vim";
  ".vimrc".source = ./vimrc;
};
```

#### 5. **Desktop & Theme Configuration**
```nix
# GTK/Qt themes, cursors, icons
gtk = {
  enable = true;
  theme.name = "Dracula";
  iconTheme.name = "Papirus-Dark";
};

home.pointerCursor = {
  gtk.enable = true;
  x11.enable = true;
  name = "Dracula-cursors";
  package = pkgs.dracula-cursors;
};
```

---

## 🔄 **What You Should Move**

### **From Home Manager to NixOS System:**

#### **1. System Services Currently in Home Manager**
```nix
# MOVE these from home/ to hosts/*/configuration.nix:

# If Syncthing is used system-wide or by multiple users
services.syncthing = {
  enable = true;
  user = "stefanmatic";  # But configure in system
  dataDir = "/home/stefanmatic/.config/syncthing";
};

# Audio system (if not already in system)
hardware.pulseaudio.enable = true;
# OR
security.rtkit.enable = true;
services.pipewire.enable = true;
```

#### **2. Hardware-Related Packages**
```nix
# MOVE from home.packages to environment.systemPackages:
environment.systemPackages = with pkgs; [
  # Hardware tools
  pciutils          # lspci
  usbutils          # lsusb  
  lm_sensors        # sensors
  
  # System monitoring (if used system-wide)
  htop
  iotop
  iftop
  
  # Hardware control
  brightnessctl     # Backlight control
  pavucontrol       # Audio control GUI
  
  # System debugging
  strace
  ltrace
  lsof
];
```

#### **3. Shell Configuration (Partial)**
```nix
# MOVE shell enablement to system, keep config in home-manager
# In system configuration:
programs.zsh.enable = true;              # System-wide zsh support
environment.shells = [ pkgs.zsh ];      # Available shells

# Keep customization in home-manager:
programs.zsh = {
  enable = true;
  # ... your personal zsh config
};
```

### **From NixOS System to Home Manager:**

#### **1. User-Specific Applications**
```nix
# MOVE from environment.systemPackages to home.packages:
home.packages = with pkgs; [
  # Development
  vscode
  dbeaver-bin
  
  # Communication  
  discord
  slack
  
  # Browsers (user choice)
  chromium
  firefox
  
  # Media
  vlc
];
```

#### **2. Language Development Tools**
```nix
# MOVE to home-manager for per-user management:
home.packages = with pkgs; [
  # DevOps tools
  kubectl
  kubectx
  kubernetes-helm
  awscli2
  terraform
  terragrunt
  
  # Programming languages
  nodejs
  python3
  go
];
```

---

## 📋 **Audit Your Current Configuration**

### **Check Your `hosts/_common/client.nix`:**

**❌ Should Move to Home Manager:**
- `chromium` → Personal browser choice
- `firefox` → Personal browser choice  
- `vscode` → Development tool
- `discord` → Communication app
- Individual development tools

**✅ Keep in System:**
- `git` → Often needed by system
- `yubikey-personalization` → Hardware support
- `pcscd` service → Hardware service
- `gnupg.agent` → System-wide service
- Desktop environment configuration

### **Check Your `home/_common.nix`:**

**❌ Should Move to System:**
- `pavucontrol` → Audio hardware control
- `brightnessctl` → Hardware control  
- `lm_sensors`, `pciutils`, `usbutils` → Hardware tools
- `htop`, `iotop`, `iftop` → System monitoring
- `strace`, `ltrace`, `lsof` → System debugging

**✅ Keep in Home Manager:**
- Personal applications (`vlc`, `discord`, etc.)
- Development tools (`kubectl`, `awscli2`)
- User scripts and dotfiles
- XDG configuration

---

## 🎯 **Best Practices**

### **1. The "Multiple Users" Test**
- If another user on the system would benefit → **NixOS System**
- If it's your personal preference → **Home Manager**

### **2. The "Root Required" Test**  
- Needs root/sudo to configure → **NixOS System**
- Can be configured as user → **Home Manager**

### **3. The "Hardware/System" Test**
- Controls hardware or system behavior → **NixOS System**
- Configures user applications → **Home Manager**

### **4. The "Service" Test**
- System daemon/service → **NixOS System**  
- User session service → **Home Manager**

---

## 🔧 **Recommended Refactor Plan**

### **Phase 1: Move Hardware/System Tools**
1. Move `lm_sensors`, `pciutils`, `usbutils` to system
2. Move `htop`, `iotop`, `iftop` to system  
3. Move `strace`, `ltrace`, `lsof` to system
4. Move `pavucontrol`, `brightnessctl` to system

### **Phase 2: Move User Applications**
1. Move browsers from system to home-manager
2. Move development IDEs to home-manager
3. Move communication apps to home-manager
4. Move media applications to home-manager

### **Phase 3: Services Audit**
1. Review each service in both configs
2. Move system services to NixOS
3. Keep user services in home-manager
4. Check for duplicates

### **Phase 4: Clean Up**
1. Remove duplicate package definitions
2. Organize modules logically
3. Document the separation in comments
4. Test configurations

This separation will give you:
- **Faster home-manager rebuilds** (fewer packages)
- **Cleaner system configuration** 
- **Better multi-user support**
- **Clearer mental model** of what goes where

---

## 📁 **Analysis of Your `user/` Directory**

After analyzing your `user/` configuration modules, here are additional recommendations for what should be moved between system and home-manager configurations:

### **✅ Correctly Placed in Home Manager (`user/`):**

#### **1. Application Configurations** 
```nix
# These are perfect for home-manager:
user/app/git/git.nix           # ✅ Personal git config
user/app/terminal/kitty.nix    # ✅ Terminal preferences  
user/app/browser/*             # ✅ Browser configurations
user/app/chat/viber.nix        # ✅ Communication apps
user/app/keepassxc.nix         # ✅ Personal password manager
user/style/stylix.nix          # ✅ Personal theming
```

#### **2. Shell Customizations**
```nix
# user/shells/sh.nix - Personal shell configuration ✅
programs.zsh = {
  enable = true;
  autosuggestion.enable = true;
  syntaxHighlighting.enable = true;
  shellAliases = myAliases;     # Personal aliases ✅
  oh-my-zsh.plugins = [...];    # Personal OMZ plugins ✅
};

home.packages = [
  disfetch lolcat cowsay        # Personal CLI fun tools ✅
  bat eza bottom fd bc          # Personal CLI alternatives ✅
  direnv nix-direnv             # Development tools ✅
  jq yq-go                      # Data processing tools ✅
];
```

#### **3. Window Manager Configuration**
```nix
# user/wm/hyprland/ - Personal WM setup ✅
wayland.windowManager.hyprland = {
  enable = true;
  settings = { };               # Personal keybinds, monitors ✅
  extraConfig = ''              # Personal WM configuration ✅
    monitor=DP-1, 3440x1440@144, 1080x45, 1
    $terminal = kitty           # Personal app preferences ✅
    bind = $mainMod, Q, exec, $terminal
  '';
};
```

#### **4. Programming Language Tools**
```nix
# user/lang/ - Development environment ✅
user/lang/python/python.nix    # ✅ Personal Python setup
user/lang/go/go.nix            # ✅ Personal Go setup  
user/lang/nodejs/nodejs.nix    # ✅ Personal Node.js setup
```

---

### **❌ Should Move from `user/` to System Config:**

#### **1. Window Manager System Support**
```nix
# MOVE from user/wm/hyprland/hyprland.nix to system config:

# In hosts/*/configuration.nix or system/wm/:
programs.hyprland = {
  enable = true;                 # System-wide WM support
  package = inputs.hyprland.packages.${pkgs.system}.hyprland;
};

# System packages needed for Hyprland
environment.systemPackages = with pkgs; [
  # These should be in system config:
  rofi                          # App launcher (system-wide)
  waybar                        # Status bar
  hyprpaper                     # Wallpaper daemon
  grim slurp                    # Screenshot tools (hardware related)
  brightnessctl                 # Hardware brightness control
  pamixer                       # Audio hardware control  
  nm-applet                     # Network manager GUI
  flameshot                     # Screenshot tool
];

# Keep personal WM configuration in home-manager:
# - Keybinds, monitor layout, personal preferences
# - Theme colors, window rules
# - Personal app assignments
```

#### **2. Shell System Enablement**
```nix
# MOVE shell enablement to system, keep customization in home-manager

# In hosts/*/configuration.nix:
programs.zsh.enable = true;              # System-wide zsh support
environment.shells = [ pkgs.zsh ];      # Available system shells
users.users.stefanmatic.shell = pkgs.zsh; # User default shell

# Keep in home-manager (user/shells/sh.nix):
programs.zsh = {
  # Personal zsh configuration only
  autosuggestion.enable = true;
  syntaxHighlighting.enable = true;
  shellAliases = myAliases;
  oh-my-zsh = { ... };
};
```

#### **3. Core CLI Tools for System Admin**
```nix
# MOVE these from user/shells/sh.nix to system packages:

# In environment.systemPackages:
environment.systemPackages = with pkgs; [
  # Core GNU tools (useful for all users/system scripts)
  gnugrep
  gnused  
  bc                           # Calculator (system scripts might need)
  
  # System administration tools
  fzf                          # Fuzzy finder (useful in system scripts)
  
  # Keep personal alternatives in home-manager:
  # bat, eza, bottom, fd, etc. - these are personal preferences
];
```

#### **4. Programming Language System Support**
```nix
# MOVE basic language support to system, keep dev tools in home-manager

# In system config:
environment.systemPackages = with pkgs; [
  python3                      # Basic Python for system scripts
  nodejs                       # If needed for system tools
  git                          # Already in your system config ✅
];

# Keep in home-manager:
home.packages = with pkgs; [
  python3Full                  # Full Python with more features
  python3.pkgs.pip             # Development package manager
  # Development-specific packages and tools
];
```

---

### **🔧 Specific Recommendations for Your Config:**

#### **1. Waybar Configuration**
```nix
# Current: user/app/waybar/waybar.nix

# SPLIT this configuration:

# MOVE to system (for multiple users):
environment.systemPackages = with pkgs; [
  waybar                       # Status bar program
  # Dependencies waybar needs:
  pamixer                      # Audio control
  brightnessctl               # Brightness control  
  playerctl                   # Media control
];

# KEEP in home-manager:
programs.waybar = {
  enable = true;
  settings = { ... };          # Personal waybar layout/modules
  style = '' ... '';           # Personal styling
};
```

#### **2. Font Management**
```nix
# Current: user/style/stylix.nix has font configuration

# MOVE font installation to system:
fonts.packages = with pkgs; [
  (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  noto-fonts-emoji
  # System-wide font availability
];

# KEEP in home-manager:
stylix.fonts = {
  monospace = {
    name = userSettings.font;    # Personal font choice
    package = userSettings.fontPkg;
  };
  # Personal font preferences and styling
};
```

#### **3. Hyprland Split Strategy**
```nix
# System config (hosts/_common/client.nix or system/wm/):
programs.hyprland = {
  enable = true;               # System WM support
  package = inputs.hyprland.packages.${pkgs.system}.hyprland;
};

xdg.portal = {
  enable = true;               # Required for Wayland apps
  extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
};

environment.systemPackages = with pkgs; [
  # System tools that Hyprland needs:
  rofi waybar grim slurp
  brightnessctl pamixer
  nm-applet
];

# Home Manager (user/wm/hyprland/):
wayland.windowManager.hyprland = {
  enable = true;
  settings = { };              # Personal configuration only
  extraConfig = ''
    # Personal keybinds, monitor setup, app preferences
  '';
};
```

---

### **📋 Updated Refactor Action Plan:**

#### **Phase 1: System Infrastructure** 
1. ✅ Move core CLI tools (`gnugrep`, `gnused`, `bc`, `fzf`) to system
2. ✅ Move window manager system support to system config  
3. ✅ Move shell enablement (`programs.zsh.enable`) to system
4. ✅ Move font installation to system config
5. ✅ Move Waybar and its dependencies to system packages

#### **Phase 2: Hardware Tools** (from previous analysis)
1. ✅ Move hardware control tools to system (`brightnessctl`, `pamixer`)
2. ✅ Move system monitoring to system (`htop`, `iotop`, `iftop`)
3. ✅ Move debugging tools to system (`strace`, `ltrace`, `lsof`)

#### **Phase 3: Personal Applications**
1. ✅ Keep all `user/app/` configurations in home-manager
2. ✅ Keep development language tools in home-manager  
3. ✅ Keep personal shell customizations in home-manager
4. ✅ Keep window manager personal config in home-manager

#### **Phase 4: Validation**
1. ✅ Test that window manager works after system/home split
2. ✅ Verify fonts are available system-wide but personally configured
3. ✅ Ensure shell works with system enablement + personal config
4. ✅ Check that development environment still functions

### **🎯 Final Architecture:**

```
System Config (hosts/):
├── Window manager support (Hyprland enable, XDG portal)
├── Core tools (basic languages, GNU tools, system fonts)  
├── Hardware control (brightness, audio, monitoring)
├── System services (SSH, Docker, etc.)
└── Desktop environment framework

Home Manager (home/):
├── Personal applications (browsers, IDEs, communication)
├── Development environments (language tools, dev packages)
├── Personal configurations (git, shell aliases, keybinds) 
├── User services (KDE connect, personal sync)
└── Themes and personal preferences
```

This creates a clean separation where system config provides the foundation and hardware access, while home-manager handles all personal preferences and user-specific applications.