# Common configuration for headless servers
# No GUI, desktop environment, or client-focused services
# Includes home-manager as NixOS module for single-command deployment
{
  inputs,
  outputs,
  config,
  pkgs,
  systemSettings,
  ...
}:

{
  imports = [
    # Home-manager as NixOS module
    inputs.home-manager.nixosModules.home-manager

    ../../system/security/firewall.nix
    ../../system/app/docker.nix
    ../../system/app/k3s.nix

    # System package modules (server-appropriate only)
    ../../system/packages/common.nix
    ../../system/packages/hardware.nix
    ../../system/packages/monitoring.nix
  ];

  config = {
    # Time and locale settings
    time.timeZone = systemSettings.timezone;
    i18n.defaultLocale = systemSettings.locale;
    i18n.extraLocaleSettings = systemSettings.extraLocaleSettings;

    # Networking configuration
    networking = {
      hostName = config.systemSettings.hostname;
      networkmanager.enable = true;
      wireguard.enable = true;
    };

    # Docker configuration
    docker.storageDriver = "overlay2";

    # SSH server
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        PrintMotd = false; # We use our own dynamic MOTD
      };
      allowSFTP = true;
    };

    # Disable default static MOTD
    users.motd = "";

    # Dynamic MOTD script
    environment.etc."profile.d/motd.sh" = {
      mode = "0755";
      text = ''
                #!/usr/bin/env bash
                # Colors
                RED='\033[0;31m'
                GREEN='\033[0;32m'
                YELLOW='\033[0;33m'
                BLUE='\033[0;34m'
                MAGENTA='\033[0;35m'
                CYAN='\033[0;36m'
                WHITE='\033[1;37m'
                GRAY='\033[0;90m'
                NC='\033[0m' # No Color
                BOLD='\033[1m'

                # Get hostname
                HOSTNAME=$(hostname)

                # ASCII art based on hostname
                case "$HOSTNAME" in
                  dell-micro-3050)
                    echo -e "''${CYAN}"
                    cat << 'LOGO'
            ╔════════════════════════════════════════════════════════════════════════════════════════╗
            ║                                                                                        ║
            ║   ███╗   ███╗██╗ ██████╗██████╗  ██████╗          ██████╗  ██████╗ ███████╗ ██████╗    ║
            ║   ████╗ ████║██║██╔════╝██╔══██╗██╔═══██╗        ╚════██╗██╔═████╗██╔════╝██╔═████╗    ║
            ║   ██╔████╔██║██║██║     ██████╔╝██║   ██║  █████╗ █████╔╝██║██╔██║███████╗██║██╔██║    ║
            ║   ██║╚██╔╝██║██║██║     ██╔══██╗██║   ██║  ╚════╝ ╚═══██╗████╔╝██║╚════██║████╔╝██║    ║
            ║   ██║ ╚═╝ ██║██║╚██████╗██║  ██║╚██████╔╝        ██████╔╝╚██████╔╝███████║╚██████╔╝    ║
            ║   ╚═╝     ╚═╝╚═╝ ╚═════╝╚═╝  ╚═╝ ╚═════╝         ╚═════╝  ╚═════╝ ╚══════╝ ╚═════╝     ║
            ║                                                                                        ║
            ╠════════════════════════════════════════════════════════════════════════════════════════╣
            ║                              MICRO-3050 • HOME LAB SERVER                              ║
            ╚════════════════════════════════════════════════════════════════════════════════════════╝
        LOGO
                    echo -e "''${NC}"
                    ;;
                  z420)
                    echo -e "''${MAGENTA}"
                    cat << 'LOGO'
            ╔═══════════════════════════════════════════════════════════════╗
            ║           ███████╗██╗  ██╗██████╗  ██████╗                    ║
            ║           ╚══███╔╝██║  ██║╚════██╗██╔═████╗                   ║
            ║             ███╔╝ ███████║ █████╔╝██║██╔██║                   ║
            ║            ███╔╝  ╚════██║██╔═══╝ ████╔╝██║                   ║
            ║           ███████╗     ██║███████╗╚██████╔╝                   ║
            ║           ╚══════╝     ╚═╝╚══════╝ ╚═════╝                    ║
            ╠═══════════════════════════════════════════════════════════════╣
            ║           HP Z420 WORKSTATION • MEDIA SERVER                  ║
            ╚═══════════════════════════════════════════════════════════════╝
        LOGO
                    echo -e "''${NC}"
                    ;;
                  *)
                    echo -e "''${BLUE}"
                    cat << 'LOGO'
            ╔═══════════════════════════════════════════════════════════════╗
            ║   ███╗   ██╗██╗██╗  ██╗ ██████╗ ███████╗    ███████╗██████╗   ║
            ║   ████╗  ██║██║╚██╗██╔╝██╔═══██╗██╔════╝    ██╔════╝██╔══██╗  ║
            ║   ██╔██╗ ██║██║ ╚███╔╝ ██║   ██║███████╗    ███████╗██████╔╝  ║
            ║   ██║╚██╗██║██║ ██╔██╗ ██║   ██║╚════██║    ╚════██║██╔══██╗  ║
            ║   ██║ ╚████║██║██╔╝ ██╗╚██████╔╝███████║    ███████║██║  ██║  ║
            ║   ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝    ╚══════╝╚═╝  ╚═╝  ║
            ╠═══════════════════════════════════════════════════════════════╣
            ║                    NIXOS SERVER                               ║
            ╚═══════════════════════════════════════════════════════════════╝
        LOGO
                    echo -e "''${NC}"
                    ;;
                esac

                # System info
                echo -e "    ''${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━''${NC}"
                echo ""

                # Get system info
                UPTIME=$(uptime -p | sed 's/up //')
                LOAD=$(cat /proc/loadavg | awk '{print $1, $2, $3}')
                MEM_TOTAL=$(free -h | awk '/^Mem:/ {print $2}')
                MEM_USED=$(free -h | awk '/^Mem:/ {print $3}')
                MEM_PERCENT=$(free | awk '/^Mem:/ {printf "%.0f", $3/$2 * 100}')
                DISK_USED=$(df -h / | awk 'NR==2 {print $3}')
                DISK_TOTAL=$(df -h / | awk 'NR==2 {print $2}')
                DISK_PERCENT=$(df / | awk 'NR==2 {print $5}')
                IP_ADDR=$(hostname -I | awk '{print $1}')
                KERNEL=$(uname -r)

                # Color code memory usage
                if [ "$MEM_PERCENT" -gt 80 ]; then
                  MEM_COLOR="''${RED}"
                elif [ "$MEM_PERCENT" -gt 60 ]; then
                  MEM_COLOR="''${YELLOW}"
                else
                  MEM_COLOR="''${GREEN}"
                fi

                # Display system info in columns
                printf "    ''${WHITE}%-12s''${NC} %-20s ''${WHITE}%-12s''${NC} %-20s\n" \
                  "Hostname:" "$HOSTNAME" "IP Address:" "$IP_ADDR"
                printf "    ''${WHITE}%-12s''${NC} %-20s ''${WHITE}%-12s''${NC} %-20s\n" \
                  "Uptime:" "$UPTIME" "Kernel:" "$KERNEL"
                printf "    ''${WHITE}%-12s''${NC} %-20s ''${WHITE}%-12s''${NC} ''${MEM_COLOR}%-20s''${NC}\n" \
                  "Load:" "$LOAD" "Memory:" "$MEM_USED / $MEM_TOTAL ($MEM_PERCENT%)"
                printf "    ''${WHITE}%-12s''${NC} %-20s ''${WHITE}%-12s''${NC} %-20s\n" \
                  "Disk /:" "$DISK_USED / $DISK_TOTAL ($DISK_PERCENT)" "NixOS:" "$(nixos-version 2>/dev/null || echo 'N/A')"

                echo ""

                # Docker status (if docker is running)
                if command -v docker &> /dev/null && docker info &> /dev/null; then
                  CONTAINERS_RUNNING=$(docker ps -q 2>/dev/null | wc -l)
                  CONTAINERS_TOTAL=$(docker ps -aq 2>/dev/null | wc -l)

                  if [ "$CONTAINERS_TOTAL" -gt 0 ]; then
                    echo -e "    ''${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━''${NC}"
                    echo -e "    ''${WHITE}Docker:''${NC} ''${GREEN}$CONTAINERS_RUNNING''${NC} running / $CONTAINERS_TOTAL total containers"
                    echo ""
                    # Show running containers
                    docker ps --format "    {{.Names}}: {{.Status}}" 2>/dev/null | head -5
                    if [ "$CONTAINERS_RUNNING" -gt 5 ]; then
                      echo -e "    ''${GRAY}... and $((CONTAINERS_RUNNING - 5)) more''${NC}"
                    fi
                    echo ""
                  fi
                fi

                # K3s status (if k3s is running)
                if command -v kubectl &> /dev/null && kubectl cluster-info &> /dev/null 2>&1; then
                  PODS_RUNNING=$(kubectl get pods -A --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l)
                  NODES=$(kubectl get nodes --no-headers 2>/dev/null | wc -l)

                  echo -e "    ''${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━''${NC}"
                  echo -e "    ''${WHITE}K3s:''${NC} ''${GREEN}$NODES''${NC} node(s), ''${GREEN}$PODS_RUNNING''${NC} running pods"
                  echo ""
                fi

                echo -e "    ''${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━''${NC}"
                echo ""
      '';
    };

    # Source the MOTD script on login for bash
    programs.bash.interactiveShellInit = ''
      # Show MOTD on login (only for interactive shells, not scp/sftp)
      if [[ $- == *i* ]] && [[ -z "$MOTD_SHOWN" ]]; then
        export MOTD_SHOWN=1
        source /etc/profile.d/motd.sh
      fi
    '';

    # Source the MOTD script on login for zsh
    programs.zsh.interactiveShellInit = ''
      # Show MOTD on login (only for interactive shells, not scp/sftp)
      if [[ -o interactive ]] && [[ -z "$MOTD_SHOWN" ]]; then
        export MOTD_SHOWN=1
        source /etc/profile.d/motd.sh
      fi
    '';

    # SSH agent auth for sudo
    security.pam = {
      services.sudo.sshAgentAuth = true;
      sshAgentAuth = {
        enable = true;
        authorizedKeysFiles = [
          "/etc/ssh/authorized_keys.d/%u"
        ];
      };
    };

    # Enable zsh system-wide
    programs.zsh.enable = true;

    # Server user configuration
    users.users.${config.userSettings.username} = {
      isNormalUser = true;
      description = config.userSettings.name;
      shell = pkgs.zsh;
      extraGroups = [
        "networkmanager"
        "wheel"
        "docker"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDJ2jVUL/jANIzKv14MfJN6bNQzYD41BJssTZiDL34sk stefan@matic.ba"
      ];
    };

    # Home-manager configuration (integrated into NixOS)
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {
        inherit inputs outputs;
        userSettings = config.userSettings;
      };
      users.${config.userSettings.username} = import ../../home/_server.nix;
    };

    # Module arguments
    _module.args = {
      inherit (config) userSettings;
    };

    # System version
    system.stateVersion = "24.11";

    # Nixpkgs configuration
    nixpkgs = {
      overlays = [
        outputs.overlays.additions
        outputs.overlays.modifications
        outputs.overlays.unstable-packages
      ];
      config = {
        allowUnfree = true;
      };
    };

    # Nix settings
    nix = {
      settings = {
        experimental-features = "nix-command flakes";
        trusted-users = [
          "root"
          config.userSettings.username
        ];
      };
      gc = {
        automatic = true;
        options = "--delete-older-than 30d";
      };
      optimise.automatic = true;
    };

    # Ghostty terminfo for SSH connections from Ghostty terminal
    environment.enableAllTerminfo = true;

    # Server-specific packages
    environment.systemPackages = with pkgs; [
      # Network tools
      tcpdump
      iperf3
      mtr

      # System tools
      tmux
      screen
    ];
  };
}
