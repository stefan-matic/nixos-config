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
        LogLevel debug2
      '';
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
        Restart = "on-failure";
        RestartSec = "5s";
      };
      path = with pkgs; [
        cups
        gutenprint
        gutenprintBin
      ];
      script = ''
        set -euo pipefail

        # Wait for CUPS to be fully started
        while ! systemctl is-active --quiet cups.service; do
          sleep 1
        done
        sleep 5

        # Debug information
        echo "=== Printer Setup Debug Information ==="
        echo "Printer: ${cfg.name}"
        echo "IP: ${cfg.ip}"
        echo "Port: ${toString cfg.port}"
        echo "Location: ${cfg.location}"
        echo "----------------------------------------"

        # Check printer status
        if lpstat -p ${cfg.name} >/dev/null 2>&1; then
          echo "Printer ${cfg.name} exists, checking configuration..."
          if ! lpstat -p ${cfg.name} -l | grep -q "enabled"; then
            echo "Printer exists but is not enabled, reconfiguring..."
            lpadmin -x ${cfg.name}
          else
            echo "Printer exists and is enabled"
            exit 0
          fi
        fi

        # Add printer with Gutenprint driver
        echo "Adding printer with Gutenprint driver..."
        if ! lpadmin -p ${cfg.name} \
          -v ipps://${cfg.ip}:${toString cfg.port} \
          -m gutenprint.5.3://triumph-adler/expert \
          -L "${cfg.location}" \
          -E; then
          echo "Failed with Gutenprint, trying generic driver..."
          if ! lpadmin -p ${cfg.name} \
            -v ipps://${cfg.ip}:${toString cfg.port} \
            -m everywhere \
            -L "${cfg.location}" \
            -E; then
            echo "Failed to add printer with any driver"
            exit 1
          fi
        fi

        # Configure printer
        echo "Configuring printer..."
        lpoptions -p ${cfg.name} -o pdftops-renderer=ghostscript
        cupsenable ${cfg.name}
        cupsaccept ${cfg.name}

        # Verify setup
        if ! lpstat -p ${cfg.name} >/dev/null 2>&1; then
          echo "Failed to verify printer setup"
          exit 1
        fi

        echo "=== Final Printer Status ==="
        lpstat -p ${cfg.name} -l
        echo "Printer setup completed successfully"
      '';
    };

    # Periodic check timer
    systemd.timers."check-${cfg.name}" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "1min";
        OnUnitActiveSec = "5min";
        Unit = "setup-${cfg.name}.service";
      };
    };
  };
}
