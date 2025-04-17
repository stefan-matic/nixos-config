{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.deej-new;

  # Get the custom packages
  customPkgs = import ../../pkgs { inherit pkgs; };

  # Create a customized config file with the right serial port and baud rate
  configFile = pkgs.writeTextFile {
    name = "deej-config.yaml";
    text = ''
      slider_mapping:
        0: master
        1:
          - chrome
        2:
          - Kiwi Clicker.exe
          - wine64-preloader
          - Kiwi
          - Warframe.x64.exe
          - Warframe
          - wine64-preloader Warframe
        3: deej.unmapped
        4: mic

      # set this to true if you want the controls inverted (i.e. top is 0%, bottom is 100%)
      invert_sliders: false

      # settings for connecting to the arduino board
      com_port: ${cfg.serialPort}
      baud_rate: ${toString cfg.baudRate}

      # adjust the amount of signal noise reduction depending on your hardware quality
      # 0.015: (excellent hardware)
      # 0.025 (regular hardware)
      # 0.035 (bad, noisy hardware)
      noise_reduction: ${toString cfg.noiseReduction}
    '';
  };
in {
  options.services.deej-new = {
    enable = mkEnableOption "deej-new service";

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

    noiseReduction = mkOption {
      type = types.float;
      default = 0.025;
      description = "Amount of noise reduction (0.015 for excellent hardware, 0.025 for regular, 0.035 for noisy)";
    };

    verbose = mkOption {
      type = types.bool;
      default = true;
      description = "Enable verbose logging";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ customPkgs.deej-new ];

    # Link the config file to the expected location
    xdg.configFile."deej/config.yaml".source = configFile;

    systemd.user.services.deej-new = {
      Unit = {
        Description = "Deej Linux - Arduino volume control";
        After = [ "graphical-session.target" "pipewire.service" "pulseaudio.service" ];
        PartOf = [ "graphical-session.target" ];
        ConditionPathExists = [ cfg.serialPort ];
      };

      Service = {
        # Environment variables
        Environment = [
          "XDG_RUNTIME_DIR=/run/user/1000"
          "PATH=${lib.makeBinPath [ pkgs.pulseaudio ]}:$PATH"
        ];

        # Setup steps before running
        ExecStartPre = [
          # Add a delay before starting to ensure audio system is ready
          "${pkgs.coreutils}/bin/sleep 3"
          # Create a directory for the service to use as working directory
          "${pkgs.coreutils}/bin/mkdir -p %h/.config/deej"
        ];

        # Run with the correct arguments - this fork has minimal CLI options
        ExecStart = "${customPkgs.deej-new}/bin/deej-linux ${optionalString cfg.verbose "-v"}";

        # Make sure we run from the directory with config.yaml
        WorkingDirectory = "%h/.config/deej";

        # Service configuration
        Restart = "on-failure";
        RestartSec = 10;

        # Set a timeout so the service doesn't get restarted unnecessarily
        TimeoutStopSec = 30;

        # Ensure it's properly supervised so systemd doesn't think it's crashed
        Type = "simple";

        # Optimize for responsiveness
        Nice = -5;
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    # Add an additional "delayed start" service to handle cases where audio isn't ready
    systemd.user.services.deej-new-delayed = {
      Unit = {
        Description = "Delayed Deej Linux Service";
        PartOf = [ "graphical-session.target" ];
        # Only start if the main service failed
        BindsTo = [ "deej-new.service" ];
        After = [ "deej-new.service" ];
        ConditionPathExists = [ cfg.serialPort ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "restart-deej-new.sh" ''
          # Wait 30 seconds after login
          sleep 30
          # Restart the main service
          systemctl --user restart deej-new.service
        '';
        RemainAfterExit = true;
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    # Ensure user has access to the serial port
    assertions = [
      {
        assertion = with config.home; username == "stefanmatic";
        message = "The deej-new service is currently only configured for stefanmatic user.";
      }
    ];
  };
}
