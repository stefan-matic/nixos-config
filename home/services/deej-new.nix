{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.deej-new;

  # Get the custom packages
  customPkgs = import ../../pkgs { inherit pkgs; };
in {
  options.services.deej-new = {
    enable = mkEnableOption "deej-new service";

    serialPort = mkOption {
      type = types.str;
      default = "/dev/ttyACM0";
      description = "Serial port to use for Arduino communication";
    };

    baudRate = mkOption {
      type = types.int;
      default = 9600;
      description = "Baud rate for serial communication";
    };

    configFile = mkOption {
      type = types.path;
      default = "${customPkgs.deej-new}/share/deej/config.yaml";
      description = "Path to the deej config file";
    };

    logFile = mkOption {
      type = types.str;
      default = "$HOME/deej.log";
      description = "Path to write logs";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ customPkgs.deej-new ];

    # Link the config file to the home directory
    xdg.configFile."deej/config.yaml".source = cfg.configFile;

    systemd.user.services.deej-new = {
      Unit = {
        Description = "Deej Linux - Arduino volume control";
        After = [ "graphical-session.target" "pipewire.service" "pulseaudio.service" ];
        PartOf = [ "graphical-session.target" ];
        ConditionPathExists = [ cfg.serialPort ];
      };

      Service = {
        # Environment variables
        Environment = [
          "XDG_RUNTIME_DIR=/run/user/1000"
          "PATH=${lib.makeBinPath [ pkgs.pulseaudio ]}:$PATH"
        ];

        # Add a delay before starting to ensure audio system is ready
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 3";

        # Run with the correct arguments
        # Note: deej-linux fork has different arguments than original deej
        ExecStart = "${customPkgs.deej-new}/bin/deej-linux --config ${cfg.configFile} --com ${cfg.serialPort} --baud ${toString cfg.baudRate} --logfile ${cfg.logFile}";

        Restart = "on-failure";
        RestartSec = 3;

        # Optimize for responsiveness
        Nice = -5;
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    # Add an additional "delayed start" service to handle cases where audio isn't ready
    systemd.user.services.deej-new-delayed = {
      Unit = {
        Description = "Delayed Deej Linux Service";
        PartOf = [ "graphical-session.target" ];
        # Only start if the main service failed
        BindsTo = [ "deej-new.service" ];
        After = [ "deej-new.service" ];
        ConditionPathExists = [ cfg.serialPort ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "restart-deej-new.sh" ''
          # Wait 30 seconds after login
          sleep 30
          # Restart the main service
          systemctl --user restart deej-new.service
        '';
        RemainAfterExit = true;
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    # Ensure user has access to the serial port
    assertions = [
      {
        assertion = with config.home; username == "stefanmatic";
        message = "The deej-new service is currently only configured for stefanmatic user.";
      }
    ];
  };
}
