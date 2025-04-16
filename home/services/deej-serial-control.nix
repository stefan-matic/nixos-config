{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.deej-serial-control;

  # Get the custom packages
  customPkgs = import ../../pkgs { inherit pkgs; };
in {
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
        After = [ "graphical-session.target" "pipewire.service" "pulseaudio.service" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 2"; # Brief delay to ensure audio is ready
        ExecStart = "${customPkgs.deej-serial-control}/bin/serial-volume-control.sh";
        Restart = "on-failure";
        RestartSec = 5;

        # Additional settings for better performance
        CPUSchedulingPolicy = "idle";
        CPUWeight = 50;
        IOSchedulingClass = "idle";
        Nice = 10;
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
