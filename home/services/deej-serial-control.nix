{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.deej-serial-control;

  # Get the custom packages
  customPkgs = import ../../pkgs { inherit pkgs; };
in {
  options.services.deej-serial-control = {
    enable = mkEnableOption "deej-serial-control service";
  };

  config = mkIf cfg.enable {
    home.packages = [ customPkgs.deej-serial-control ];

    systemd.user.services.serial-volume-control = {
      Unit = {
        Description = "Arduino Serial Volume Control";
        After = [ "graphical-session.target" "pipewire.service" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Environment = "XDG_RUNTIME_DIR=/run/user/1000";
        ExecStart = "${customPkgs.deej-serial-control}/bin/serial-volume-control.sh";
        Restart = "on-failure";
        RestartSec = 5;
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
