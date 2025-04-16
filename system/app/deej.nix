{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.apps.deej;
  customPkgs = import ../../pkgs { inherit pkgs; };
in {
  options.apps.deej = {
    enable = mkEnableOption "deej Arduino volume control";
    user = mkOption {
      type = types.str;
      default = "stefanmatic";
      description = "User to run the deej service as";
    };
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
    # Make the package available system-wide
    environment.systemPackages = [ customPkgs.deej-serial-control ];

    # Add user to dialout group for Arduino access
    users.users.${cfg.user}.extraGroups = [ "dialout" ];

    # Add udev rules for Arduino
    services.udev.extraRules = ''
      SUBSYSTEM=="tty", ATTRS{idVendor}=="2341", ATTRS{idProduct}=="*", GROUP="dialout", MODE="0660"
      SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="*", GROUP="dialout", MODE="0660"
      SUBSYSTEM=="tty", ATTRS{idVendor}=="2a03", ATTRS{idProduct}=="*", GROUP="dialout", MODE="0660"
    '';

    # Create a system service that starts at boot
    systemd.services.deej-serial-control = {
      description = "Arduino Serial Volume Control";
      wantedBy = [ "multi-user.target" ];

      # Wait for the user's session to be active
      requires = [ "network.target" ];
      after = [ "network.target" "sound.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = "users";
        ExecStart = "${customPkgs.deej-serial-control}/bin/serial-volume-control.sh";
        Restart = "always";
        RestartSec = "5s";

        # Performance optimizations
        CPUSchedulingPolicy = "idle";
        CPUWeight = 50;
        IOSchedulingClass = "idle";
        Nice = 10;
      };
    };
  };
}
