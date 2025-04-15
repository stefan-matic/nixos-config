{ config, lib, pkgs, ... }:

let
  cfg = config.hardware.printers.TA-p-4025w;
in {
  options.hardware.printers.TA-p-4025w = {
    enable = lib.mkEnableOption "Triumph Adler P-4025w printer";
    ip = lib.mkOption {
      type = lib.types.str;
      default = "10.100.10.251";
      description = "IP address of the printer";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 633;
      description = "Port number of the printer";
    };
    name = lib.mkOption {
      type = lib.types.str;
      default = "Matic-Printer";
      description = "Name of the printer in CUPS";
    };
    location = lib.mkOption {
      type = lib.types.str;
      default = "Home";
      description = "Location description of the printer";
    };
  };

  config = lib.mkIf cfg.enable {
    # Add required packages
    environment.systemPackages = with pkgs; [
      ghostscript
      cups-filters
      gutenprint
      gutenprintBin
    ];

    # Configure CUPS
    services.printing = {
      enable = true;
      drivers = with pkgs; [
        gutenprint
        gutenprintBin
      ];
      extraConf = ''
        # Use Ghostscript for PDF rendering
        pdftops-renderer ghostscript
        pdftops-renderer-default ghostscript
      '';
      logLevel = "debug";  # Enable debug logging
    };

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    # Printer setup service
    systemd.services."setup-${cfg.name}" = {
      description = "Setup ${cfg.name}";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "cups.service" ];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        RemainAfterExit = true;
      };
      script = ''
        # Wait for CUPS to be fully started
        while ! systemctl is-active --quiet cups.service; do
          sleep 1
        done
        sleep 5  # Additional wait to ensure CUPS is fully initialized

        # Remove existing printer if it exists
        /run/current-system/sw/bin/lpadmin -x ${cfg.name} || true

        # List available drivers for debugging
        echo "Available drivers:"
        /run/current-system/sw/bin/lpinfo -m | grep -i "triumph\|adler" || true

        # Add the printer using a generic driver first
        if ! /run/current-system/sw/bin/lpadmin -p ${cfg.name} \
          -v ipps://${cfg.ip}:${toString cfg.port} \
          -m everywhere \
          -L "${cfg.location}" \
          -E; then
          echo "Failed to add printer with generic driver, trying Gutenprint..."
          if ! /run/current-system/sw/bin/lpadmin -p ${cfg.name} \
            -v ipps://${cfg.ip}:${toString cfg.port} \
            -m gutenprint.5.3://triumph-adler/expert \
            -L "${cfg.location}" \
            -E; then
            echo "Failed to add printer with Gutenprint driver"
            exit 1
          fi
        fi

        # Set the printer to use Ghostscript for PDF rendering
        /run/current-system/sw/bin/lpoptions -p ${cfg.name} -o pdftops-renderer=ghostscript

        # Enable the printer
        /run/current-system/sw/bin/cupsenable ${cfg.name}
        /run/current-system/sw/bin/cupsaccept ${cfg.name}

        # Verify printer setup
        if ! /run/current-system/sw/bin/lpstat -p ${cfg.name}; then
          echo "Failed to verify printer setup"
          exit 1
        fi
      '';
    };
  };
}
