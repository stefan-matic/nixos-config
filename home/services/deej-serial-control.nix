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
        Environment = "XDG_RUNTIME_DIR=/run/user/1000";
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
  };
}
