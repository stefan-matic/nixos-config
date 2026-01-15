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

    # Arcade specific configuration

    # Enable X11 for arcade display
    services.xserver = {
      enable = true;
      displayManager = {
        lightdm.enable = true;
        autoLogin = {
          enable = true;
          user = userSettings.username;
        };
      };
      # Optimize for retro gaming display
      serverFlagsSection = ''
        Option "BlankTime" "0"
        Option "StandbyTime" "0"
        Option "SuspendTime" "0"
        Option "OffTime" "0"
      '';
    };

    # Arcade and emulation packages
    environment.systemPackages = with pkgs; [
      # RetroArch and emulators
      retroarch

      # Individual emulator cores (install as needed)
      libretro.beetle-psx-hw
      libretro.dolphin
      libretro.flycast
      libretro.gambatte
      libretro.genesis-plus-gx
      libretro.mame
      libretro.mupen64plus
      libretro.nestopia
      libretro.pcsx2
      libretro.snes9x

      # Alternative standalone emulators
      mame
      mednafen

      # Audio/Video
      alsa-utils
      pulseaudio

      # Joystick/Controller support
      linuxConsoleTools
      jstest-gtk

      # ROM management
      unzip
      p7zip

      # System monitoring
      htop

      # Network tools
      wget
      curl
    ];

    # Audio configuration for arcade sounds
    sound.enable = true;
    hardware.pulseaudio.enable = true;

    # Enable joystick/gamepad support
    hardware.steam-hardware.enable = true;

    # Add user to input group for controller access
    users.users.${userSettings.username}.extraGroups = [
      "input"
      "audio"
    ];

    # Udev rules for arcade controllers and joysticks
    services.udev.extraRules = ''
      # Generic USB joystick/gamepad support
      SUBSYSTEM=="input", GROUP="input", MODE="0664"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="028e", MODE="0664", GROUP="input"

      # Arcade-specific controller support
      KERNEL=="js[0-9]*", MODE="0664", GROUP="input"
      KERNEL=="event[0-9]*", MODE="0664", GROUP="input"
    '';

    # Auto-start RetroArch frontend
    systemd.user.services.arcade-frontend = {
      description = "Arcade Frontend Service";
      after = [ "graphical-session.target" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "5";
        ExecStart = "${pkgs.retroarch}/bin/retroarch";
        User = userSettings.username;
      };
      environment = {
        DISPLAY = ":0";
        PULSE_RUNTIME_PATH = "/run/user/1000/pulse";
      };
    };

    # Enable automatic login for arcade experience
    services.getty.autologinUser = userSettings.username;

    # Disable power management for always-on arcade
    systemd.targets.sleep.enable = false;
    systemd.targets.suspend.enable = false;
    systemd.targets.hibernate.enable = false;
    systemd.targets.hybrid-sleep.enable = false;

    powerManagement = {
      enable = false;
      powertop.enable = false;
    };

    # Create directories for ROMs (user will need to add ROMs manually)
    systemd.tmpfiles.rules = [
      "d /home/${userSettings.username}/ROMs 0755 ${userSettings.username} users -"
      "d /home/${userSettings.username}/ROMs/arcade 0755 ${userSettings.username} users -"
      "d /home/${userSettings.username}/ROMs/nes 0755 ${userSettings.username} users -"
      "d /home/${userSettings.username}/ROMs/snes 0755 ${userSettings.username} users -"
      "d /home/${userSettings.username}/ROMs/gameboy 0755 ${userSettings.username} users -"
      "d /home/${userSettings.username}/ROMs/gba 0755 ${userSettings.username} users -"
      "d /home/${userSettings.username}/ROMs/n64 0755 ${userSettings.username} users -"
      "d /home/${userSettings.username}/ROMs/psx 0755 ${userSettings.username} users -"
      "d /home/${userSettings.username}/ROMs/genesis 0755 ${userSettings.username} users -"
    ];
  };
}
