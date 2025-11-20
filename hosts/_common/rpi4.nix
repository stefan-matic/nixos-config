# Raspberry Pi 4 specific configuration template
# This template imports the common RPI configuration with Pi 4 settings

{
  lib,
  inputs,
  outputs,
  config,
  pkgs,
  userSettings,
  systemSettings,
  ...
}: {
  imports = [
    (import ./rpi-common.nix {
      inherit lib inputs outputs config pkgs userSettings systemSettings;
      piModel = "4";
    })
  ];

  # Pi 4 specific overrides and additions can go here
  
  # Pi 4 has more resources, so we can enable some additional features
  environment.systemPackages = with pkgs; [
    # Additional tools that Pi 4 can handle
    docker-compose  # If using containers
    
    # Video/graphics tools (Pi 4 has better GPU)
    ffmpeg-headless
    
    # Development tools
    python3
    nodejs
  ];

  # Pi 4 specific optimizations
  services = {
    # Enable more services that Pi 4 can handle
    fstrim.enable = true;  # SSD trim support if using USB storage
    
    # Optimize for better performance
    journald.extraConfig = lib.mkAfter ''
      SystemMaxFileSize=50M
      SystemKeepFree=500M
    '';
  };

  # Pi 4 network optimizations
  networking = {
    # Pi 4 can handle more network connections
    firewall = {
      # More generous connection tracking for Pi 4
      connectionTrackingModules = [ "ftp" "irc" "sane" ];
    };
  };

  # Hardware-specific features for Pi 4
  hardware = {
    # Enable additional hardware features
    bluetooth.enable = lib.mkDefault false;  # Can be enabled per host
    
    # Pi 4 specific GPIO/hardware support
    i2c.enable = lib.mkDefault false;
    spi.enable = lib.mkDefault false;
  };
}