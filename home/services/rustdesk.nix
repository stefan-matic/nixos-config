{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.rustdesk;
in {
  options.services.rustdesk = {
    enable = mkEnableOption "RustDesk remote desktop service";
  };

  config = mkIf cfg.enable {
    systemd.user.services.rustdesk = {
      Unit = {
        Description = "RustDesk Remote Desktop Service";
        After = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${pkgs.rustdesk}/bin/rustdesk --service";
        Type = "simple";
        Restart = "on-failure";
        RestartSec = 5;
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
