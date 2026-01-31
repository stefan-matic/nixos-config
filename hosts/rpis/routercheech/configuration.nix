{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  env = import ./env.nix { inherit pkgs; };
  inherit (env) systemSettings userSettings;
in

{
  imports = [
    ./hardware-configuration.nix
    ../../_common/rpi4.nix
  ];

  options = {
    userSettings = lib.mkOption {
      type = lib.types.attrs;
      default = userSettings;
      description = "User settings including username";
    };

    systemSettings = lib.mkOption {
      type = lib.types.attrs;
      default = systemSettings;
      description = "System settings including hostname";
    };
  };

  config = {
    # Pass settings to child modules
    _module.args = {
      inherit systemSettings userSettings;
    };

    # Agenix secrets (secrets.nix at repo root, .age files in secrets/)
    age.secrets.wifi-routercheech = {
      file = ../../../secrets/wifi-routercheech.age; # Path from this file to secrets/
      owner = "root";
      group = "root";
      mode = "0400";
    };

    # Router/Gateway specific configuration

    # Disable X11 - this is a headless router
    services.xserver.enable = false;

    # Enable IP forwarding for routing
    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };

    # Network configuration for router functionality
    networking = {
      # Disable default DHCP - we'll configure interfaces manually
      useDHCP = false;

      # Configure network interfaces
      interfaces = {
        # WAN interface (adjust interface name as needed)
        eth0 = {
          useDHCP = true; # Get IP from upstream router/ISP
        };

        # LAN interface configuration (if using USB-to-Ethernet adapter)
        # eth1 = {
        #   ipv4.addresses = [{
        #     address = "192.168.1.1";
        #     prefixLength = 24;
        #   }];
        # };

        # WiFi AP configuration
        wlan0 = {
          ipv4.addresses = [
            {
              address = "192.168.100.1";
              prefixLength = 24;
            }
          ];
        };
      };

      # Firewall configuration
      firewall = {
        enable = true;
        allowedTCPPorts = [
          22 # SSH
          53 # DNS
          67 # DHCP
          80 # HTTP (for web interface)
          443 # HTTPS (for web interface)
        ];
        allowedUDPPorts = [
          53 # DNS
          67 # DHCP
          68 # DHCP
        ];

        # Enable NAT for router functionality
        extraCommands = ''
          # NAT rules for internet sharing
          iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
          iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT
          iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
        '';
      };
    };

    # WiFi Access Point configuration
    services.hostapd = {
      enable = true;
      radios.wlan0 = {
        band = "2g";
        channel = 6;
        countryCode = "RS";

        networks.wlan0 = {
          ssid = "RouterCheech-WiFi";
          authentication = {
            mode = "wpa2-sha256";
            wpaPasswordFile = config.age.secrets.wifi-routercheech.path;
          };
        };
      };
    };

    # DHCP server for LAN clients
    services.dhcpd4 = {
      enable = true;
      interfaces = [ "wlan0" ];
      extraConfig = ''
        subnet 192.168.100.0 netmask 255.255.255.0 {
          range 192.168.100.10 192.168.100.254;
          option routers 192.168.100.1;
          option domain-name-servers 192.168.100.1, 8.8.8.8;
          default-lease-time 86400;
          max-lease-time 86400;
        }
      '';
    };

    # DNS server (dnsmasq for caching and local resolution)
    services.dnsmasq = {
      enable = true;
      settings = {
        # Listen on LAN interface
        interface = [ "wlan0" ];
        bind-interfaces = true;

        # Upstream DNS servers
        server = [
          "8.8.8.8"
          "8.8.4.4"
          "1.1.1.1"
        ];

        # Cache settings
        cache-size = 1000;

        # Local domain
        domain = "router.local";

        # DHCP integration (if not using dhcpd4)
        # dhcp-range = "192.168.100.10,192.168.100.254,24h";
        # dhcp-option = "option:router,192.168.100.1";
        # dhcp-option = "option:dns-server,192.168.100.1";
      };
    };

    # Network monitoring and management packages
    environment.systemPackages = with pkgs; [
      # Network tools
      iptables
      iproute2
      bridge-utils
      wireless-tools
      iw

      # Monitoring
      bandwhich
      iftop
      netstat-nat
      tcpdump
      wireshark-cli

      # System tools
      htop
      tmux

      # Web interface (optional)
      nginx
    ];

    # Optional: Simple web interface for router management
    services.nginx = {
      enable = true;
      virtualHosts."routercheech.local" = {
        listen = [
          {
            addr = "192.168.100.1";
            port = 80;
          }
        ];
        locations."/" = {
          root = "/var/www/routercheech";
          index = "index.html";
        };
      };
    };

    # Create web interface directory
    systemd.tmpfiles.rules = [
      "d /var/www/routercheech 0755 nginx nginx -"
    ];

    # Enable systemd network wait for proper startup
    systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;
    systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;

    # Power optimization for 24/7 operation
    powerManagement = {
      enable = true;
      cpuFreqGovernor = "powersave";
    };

    # Reduce logging to extend SD card life
    services.journald.extraConfig = ''
      SystemMaxUse=50M
      RuntimeMaxUse=25M
    '';

    # NTP for accurate time (important for logs and certs)
    services.ntp.enable = true;
  };
}
