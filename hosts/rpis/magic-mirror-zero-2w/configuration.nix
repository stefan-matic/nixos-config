{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  env = import ./env.nix { inherit pkgs; };
  inherit (env) systemSettings userSettings;
in

{
  imports = [
    ./hardware-configuration.nix
    ../../_common/rpi-zero2w.nix
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

    # Magic Mirror specific configuration optimized for Pi Zero 2W

    # Enable X11 for display output with minimal footprint
    services.xserver = {
      enable = true;
      displayManager = {
        lightdm = {
          enable = true;
          # Reduce lightdm memory usage
          greeters.tiny = {
            enable = false;
          };
        };
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

      # Optimize X11 for Pi Zero 2W limited resources
      config = ''
        Section "Device"
          Identifier "BCM2835 HDMI"
          Driver "modesetting"
          Option "SWCursor" "true"
        EndSection
      '';
    };

    # Magic Mirror application packages - minimal set for Zero 2W
    environment.systemPackages = with pkgs; [
      # Essential Node.js for MagicMirror (use LTS version)
      nodejs_18 # Lighter than latest nodejs

      # Minimal browser - consider using a lighter alternative
      chromium

      # Essential tools only
      git
      wget

      # Zero 2W specific tools
      i2c-tools

      # Minimal system monitoring
      htop
    ];

    # Optimized Magic Mirror display service for Zero 2W
    systemd.user.services.magic-mirror-display = {
      description = "Magic Mirror Display Service (Zero 2W Optimized)";
      after = [ "graphical-session.target" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "10"; # Longer restart delay for stability
        # Optimized Chromium flags for Pi Zero 2W
        ExecStart = "${pkgs.chromium}/bin/chromium --kiosk --disable-infobars --disable-session-crashed-bubble --disable-restore-session-state --disable-web-security --allow-running-insecure-content --no-first-run --disable-translate --disable-features=TranslateUI,VizDisplayCompositor --disk-cache-dir=/tmp --aggressive-cache-discard --memory-pressure-off --max_old_space_size=128 --disable-background-timer-throttling --disable-renderer-backgrounding --disable-backgrounding-occluded-windows --disable-features=AudioServiceOutOfProcess http://localhost:8080";

        # Resource limits for Zero 2W
        MemoryHigh = "200M";
        MemoryMax = "300M";
        CPUQuota = "80%";
      };
      environment = {
        DISPLAY = ":0";
        # Reduce GPU memory pressure
        CHROMIUM_FLAGS = "--disable-gpu-memory-buffer-compositor-resources";
      };
    };

    # Optimized Magic Mirror application service for Zero 2W
    systemd.user.services.magic-mirror = {
      description = "Magic Mirror Application (Zero 2W Optimized)";
      after = [ "network.target" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "15"; # Longer restart delay
        WorkingDirectory = "/home/${userSettings.username}/MagicMirror";
        ExecStart = "${pkgs.nodejs_18}/bin/npm start";
        User = userSettings.username;

        # Strict resource limits for Zero 2W
        MemoryHigh = "150M";
        MemoryMax = "200M";
        CPUQuota = "70%";
      };
      environment = {
        # Node.js memory optimization for Pi Zero 2W
        NODE_OPTIONS = "--max-old-space-size=128 --gc-interval=100";
      };
    };

    # Enable automatic login for seamless experience
    services.getty.autologinUser = userSettings.username;

    # Network configuration for Magic Mirror
    networking.firewall = {
      allowedTCPPorts = [ 8080 ]; # MagicMirror default port
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

    # Pi Zero 2W specific optimizations for Magic Mirror

    # Create MagicMirror directory with proper permissions
    systemd.tmpfiles.rules = [
      "d /home/${userSettings.username}/MagicMirror 0755 ${userSettings.username} users -"
      "d /home/${userSettings.username}/MagicMirror/config 0755 ${userSettings.username} users -"
      "d /home/${userSettings.username}/MagicMirror/modules 0755 ${userSettings.username} users -"
    ];

    # Optimize system services for Pi Zero 2W + Magic Mirror
    systemd.services = {
      # Reduce NetworkManager resource usage
      NetworkManager.serviceConfig = {
        MemoryHigh = "32M";
        MemoryMax = "64M";
      };

      # Optimize systemd-logind
      systemd-logind.serviceConfig = {
        MemoryHigh = "16M";
        MemoryMax = "32M";
      };
    };

    # Additional Zero 2W optimizations for display applications
    boot.kernelParams = [
      # Optimize for display/graphics performance on limited hardware
      "cma=64M" # Sufficient for basic display, less than Pi 4
      "gpu_mem=32" # Slightly more than minimum for smooth display
    ];

    # Firmware configuration specific to Magic Mirror Zero 2W
    sdImage.extraFirmwareConfig = {
      # Display optimization for Magic Mirror
      start_x = 0; # Disable camera
      gpu_mem = 32; # Balanced for display + memory

      # Force specific resolution for better performance
      hdmi_group = 2; # DMT
      hdmi_mode = 82; # 1920x1080 60Hz (adjust as needed)

      # Optimize for HDMI display
      hdmi_force_hotplug = 1;
      hdmi_drive = 2;

      # Audio optimization
      dtparam = "audio=off"; # Disable audio to save resources
    };

    # Minimal font packages for display
    fonts.packages = with pkgs; [
      liberation_ttf # Smaller than full font packages
      noto-fonts-emoji-blob-bin # For emoji support in Magic Mirror
    ];
  };
}
