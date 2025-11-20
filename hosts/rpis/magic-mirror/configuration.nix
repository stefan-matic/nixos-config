{ config, pkgs, lib, inputs, ... }:

let
  env = import ./env.nix {inherit pkgs; };
  inherit (env) systemSettings userSettings;
in

{
  imports = [
    ./hardware-configuration.nix
    ../../_common/rpi4.nix
  ];

  options = {
    userSettings = lib.mkOption {
      type = lib.types.attrs;
      default = userSettings;
      description = "User settings including username";
    };

    systemSettings = lib.mkOption {
      type = lib.types.attrs;
      default = systemSettings;
      description = "System settings including hostname";
    };
  };

  config = {
    # Pass settings to child modules
    _module.args = {
      inherit systemSettings userSettings;
    };

    # Magic Mirror specific configuration
    
    # Enable X11 for display output
    services.xserver = {
      enable = true;
      displayManager = {
        lightdm.enable = true;
        autoLogin = {
          enable = true;
          user = userSettings.username;
        };
      };
      # Disable screen blanking for always-on display
      serverFlagsSection = ''
        Option "BlankTime" "0"
        Option "StandbyTime" "0"
        Option "SuspendTime" "0"
        Option "OffTime" "0"
      '';
    };

    # Magic Mirror application packages
    environment.systemPackages = with pkgs; [
      # Node.js for MagicMirror
      nodejs
      npm
      
      # Display and browser packages
      chromium
      
      # Git for cloning MagicMirror
      git
      
      # System monitoring
      htop
      
      # Network tools
      wget
      curl
    ];

    # Auto-start Chromium in kiosk mode for Magic Mirror
    systemd.user.services.magic-mirror-display = {
      description = "Magic Mirror Display Service";
      after = [ "graphical-session.target" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "5";
        ExecStart = "${pkgs.chromium}/bin/chromium --kiosk --disable-infobars --disable-session-crashed-bubble --disable-restore-session-state --disable-web-security --allow-running-insecure-content --no-first-run --fast --fast-start --disable-translate --disable-features=TranslateUI --disk-cache-dir=/tmp --aggressive-cache-discard http://localhost:8080";
      };
      environment = {
        DISPLAY = ":0";
      };
    };

    # Create magic mirror user service directory
    systemd.user.services.magic-mirror = {
      description = "Magic Mirror Application";
      after = [ "network.target" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "10";
        WorkingDirectory = "/home/${userSettings.username}/MagicMirror";
        ExecStart = "${pkgs.nodejs}/bin/npm start";
        User = userSettings.username;
      };
    };

    # Enable automatic login for seamless experience
    services.getty.autologinUser = userSettings.username;

    # Network configuration for Magic Mirror
    networking.firewall = {
      allowedTCPPorts = [ 8080 ];  # MagicMirror default port
    };

    # Disable power management to keep display always on
    systemd.targets.sleep.enable = false;
    systemd.targets.suspend.enable = false;
    systemd.targets.hibernate.enable = false;
    systemd.targets.hybrid-sleep.enable = false;

    # Override screen power management
    powerManagement = {
      enable = false;
      powertop.enable = false;
    };
  };
}