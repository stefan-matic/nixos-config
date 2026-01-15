{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.deej-serial-control;

  # Get the custom packages
  customPkgs = import ../../pkgs { inherit pkgs; };
in
{
  options.services.deej-serial-control = {
    enable = mkEnableOption "deej-serial-control service";

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
  };

  config = mkIf cfg.enable {
    home.packages = [ customPkgs.deej-serial-control ];

    systemd.user.services.serial-volume-control = {
      Unit = {
        Description = "Arduino Serial Volume Control";
        After = [
          "graphical-session.target"
          "pipewire.service"
          "pulseaudio.service"
        ];
        PartOf = [ "graphical-session.target" ];
        ConditionPathExists = [ cfg.serialPort ];

        # Delay startup to ensure audio system is ready
        StartLimitIntervalSec = 5;
        StartLimitBurst = 3;
      };

      Service = {
        # Environment variables
        Environment = [
          "XDG_RUNTIME_DIR=/run/user/1000"
          "PATH=${pkgs.pulseaudio}/bin:${pkgs.bash}/bin:${pkgs.coreutils}/bin:${pkgs.gnugrep}/bin:${pkgs.gnused}/bin:/run/current-system/sw/bin"
        ];

        # Add a delay before starting to ensure audio system is ready
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 3";
        ExecStart = "${customPkgs.deej-serial-control}/bin/serial-volume-control.sh";
        Restart = "on-failure";
        RestartSec = 3;

        # Optimize for responsiveness but use supported policies
        Nice = -5;
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    # Add an additional "delayed start" service to handle cases where audio isn't ready
    systemd.user.services.serial-volume-control-delayed = {
      Unit = {
        Description = "Delayed Arduino Serial Volume Control";
        PartOf = [ "graphical-session.target" ];
        # Only start if the main service failed
        BindsTo = [ "serial-volume-control.service" ];
        After = [ "serial-volume-control.service" ];
        ConditionPathExists = [ cfg.serialPort ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "restart-deej.sh" ''
          # Wait 30 seconds after login
          sleep 30
          # Restart the main service
          systemctl --user restart serial-volume-control.service
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
        message = "The deej-serial-control service is currently only configured for stefanmatic user.";
      }
    ];
  };
}
