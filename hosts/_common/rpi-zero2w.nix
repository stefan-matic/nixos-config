# Raspberry Pi Zero 2W specific configuration template
# This template imports the common RPI configuration with Zero 2W settings

{
  lib,
  inputs,
  outputs,
  config,
  pkgs,
  userSettings,
  systemSettings,
  ...
}:
{
  imports = [
    (import ./rpi-common.nix {
      inherit
        lib
        inputs
        outputs
        config
        pkgs
        userSettings
        systemSettings
        ;
      piModel = "zero2w";
    })
  ];

  # Pi Zero 2W specific overrides and additions can go here

  # Example: Enable specific GPIO features commonly used with Pi Zero 2W
  # hardware.spi.enable = true;  # Uncomment if you need SPI
  # hardware.i2c.enable = true;  # Already enabled by default in rpi-common.nix

  # Zero 2W optimizations for very limited resources
  services = {
    # Disable some services that might not be needed
    udisks2.enable = lib.mkDefault false;

    # Optimize journald further for minimal storage
    journald.extraConfig = lib.mkAfter ''
      SystemMaxFileSize=10M
      SystemKeepFree=100M
    '';
  };

  # Additional Zero 2W specific packages
  environment.systemPackages = with pkgs; [
    # Useful for GPIO and hardware projects
    python3Packages.rpi-gpio
    python3Packages.gpiozero

    # Minimal system monitoring
    lm_sensors
  ];

  # Network optimization for slower hardware
  networking = {
    # Reduce network timeouts
    dhcpcd.wait = "background";

    # Optimize for slower WiFi performance
    wireless = {
      interfaces = [ "wlan0" ];
      # Add power saving options if needed
      # networks.<network>.extraConfig = ''
      #   scan_ssid=1
      #   priority=10
      # '';
    };
  };

  # System resource limits for Zero 2W
  systemd = {
    # Reduce resource usage of systemd services
    services = {
      systemd-timesyncd.serviceConfig = {
        MemoryHigh = "8M";
        MemoryMax = "16M";
      };

      # Limit SSH memory usage
      sshd.serviceConfig = {
        MemoryHigh = "16M";
        MemoryMax = "32M";
      };
    };

    # Optimize tmpfiles for limited storage
    tmpfiles.rules = [
      # Clean temporary files more aggressively
      "D /tmp 0755 root root 1d"
      "D /var/tmp 0755 root root 7d"
    ];
  };
}
