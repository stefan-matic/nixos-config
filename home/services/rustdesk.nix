{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.rustdesk;

  # Wrapper script to fix chrono timezone crash
  rustdesk-wrapped = pkgs.writeShellScriptBin "rustdesk-wrapped" ''
    export TZ=:/etc/localtime
    # Disable all logging to avoid chrono crash
    export RUST_LOG=off
    exec ${pkgs.rustdesk}/bin/rustdesk "$@"
  '';
in {
  options.services.rustdesk = {
    enable = mkEnableOption "RustDesk remote desktop service";
  };

  config = mkIf cfg.enable {
    systemd.user.services.rustdesk = {
      Unit = {
        Description = "RustDesk Remote Desktop Service";
        After = [ "graphical-session.target" "pipewire.service" "xdg-desktop-portal.service" ];
        Wants = [ "pipewire.service" "xdg-desktop-portal.service" ];
      };

      Service = {
        ExecStart = "${rustdesk-wrapped}/bin/rustdesk-wrapped --service";
        Type = "simple";
        Restart = "on-failure";
        RestartSec = 5;

        # Wayland environment variables for screen sharing
        # Make RustDesk think it's running on GNOME for better Wayland compatibility
        Environment = [
          "XDG_SESSION_TYPE=wayland"
          "XDG_CURRENT_DESKTOP=GNOME"
          "XDG_SESSION_DESKTOP=gnome"
          "QT_QPA_PLATFORM=wayland"
          "WAYLAND_DISPLAY=wayland-1"
        ];
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
