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
  customPkgs = import ../../pkgs { inherit pkgs; };
in

{
  imports = [
    ./hardware-configuration.nix
    ../_common/client.nix
    ./packages.nix # T14-specific system packages
    ./prefetch.nix # Periodic background prefetch of system closure
    # Import DMS NixOS module
    inputs.dms.nixosModules.dank-material-shell
    # DMS greeter (greetd) — replaces SDDM
    inputs.dms.nixosModules.greeter
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

    # Home-manager user configuration
    home-manager.extraSpecialArgs.terminalFontSize = 9; # Laptop screen
    home-manager.users.${userSettings.username} = {
      imports = [
        ../../home/stefanmatic.nix
        ../../user/wm/niri/laptop.nix
      ];
    };

    # Bootloader configuration
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Syncthing - system service for user
    services.syncthing = {
      enable = true;
      user = userSettings.username;
      dataDir = "/home/${userSettings.username}/.config/syncthing";
      configDir = "/home/${userSettings.username}/.config/syncthing";
      settings = {
        gui = {
          theme = "dark";
          user = userSettings.username;
        };
        devices = {
          unraid = {
            id = "2T25XJC-SXWEDMA-DF4P57K-55AQCXQ-2MYHHLJ-IXF24KU-HNMUWRN-4W2R3AY";
          };
        };
        folders = {
          "dotfiles" = {
            path = "/home/${userSettings.username}/";
            devices = [ "unraid" ];
            id = "dotfiles";
          };
          "KeePass" = {
            path = "/home/${userSettings.username}/KeePass";
            devices = [ "unraid" ];
            id = "72iax-2g67s";
          };
          "Desktop" = {
            path = "/home/${userSettings.username}/Desktop";
            devices = [ "unraid" ];
            id = "b4w9b-c7epm";
          };
          "Documents" = {
            path = "/home/${userSettings.username}/Documents";
            devices = [ "unraid" ];
            id = "zmgjt-pjaqa";
          };
          "Pictures" = {
            path = "/home/${userSettings.username}/Pictures";
            devices = [ "unraid" ];
            id = "bnzvt-hpsu6";
          };
          "Videos" = {
            path = "/home/${userSettings.username}/Videos";
            devices = [ "unraid" ];
            id = "uzfcf-ijz7p";
          };
          "Scripts" = {
            path = "/home/${userSettings.username}/Scripts";
            devices = [ "unraid" ];
            id = "udqbf-4zpw3";
          };
          "Workspace" = {
            path = "/home/${userSettings.username}/Workspace";
            devices = [ "unraid" ];
            id = "cypve-yruqr";
          };
          "Claude Code" = {
            path = "/home/${userSettings.username}/.claude";
            devices = [ "unraid" ];
            id = "crwsq-yjurj";
          };
        };
      };
    };

    # DMS greeter replaces SDDM (set in _common/client.nix). greetd handles
    # login via the same Niri+DMS stack used in the session. Wallpaper +
    # theme are copied from configHome on each greetd preStart.
    services.displayManager.sddm.enable = lib.mkForce false;
    programs.dank-material-shell.greeter = {
      enable = true;
      compositor.name = "niri";
      compositor.customConfig = builtins.readFile ../../user/wm/dms/greeter-niri.kdl;
      configHome = "/home/${userSettings.username}";
    };

    # User must be in `greeter` group for `dms greeter sync` and status checks.
    users.users.${userSettings.username}.extraGroups = [ "greeter" ];

    # NixOS greetd module passes --config from /nix/store directly; mirror it
    # at /etc/greetd/config.toml so `dms greeter status` can detect the install.
    environment.etc."greetd/config.toml".source =
      (pkgs.formats.toml { }).generate "greetd.toml" config.services.greetd.settings;

    # Pre-create XDG subdirs that `dms greeter status` expects.
    systemd.tmpfiles.settings."20-dms-greeter-xdg" = {
      "/var/lib/dms-greeter/.local/state".d = { user = "greeter"; group = "greeter"; mode = "0755"; };
      "/var/lib/dms-greeter/.local/share".d = { user = "greeter"; group = "greeter"; mode = "0755"; };
      "/var/lib/dms-greeter/.cache".d        = { user = "greeter"; group = "greeter"; mode = "0755"; };
    };

    # Pre-seed greeter memory so username pre-fills on first boot. Subsequent
    # logins auto-update memory.json via DMS itself.
    systemd.services.greetd.preStart = lib.mkAfter ''
      state_dir="/var/lib/dms-greeter/.local/state"
      mkdir -p "$state_dir"
      if [ ! -f "$state_dir/memory.json" ]; then
        echo '{"lastSuccessfulUser":"${userSettings.username}"}' > "$state_dir/memory.json"
        chown -R greeter:greeter /var/lib/dms-greeter/.local || true
      fi
    '';

    # Remap Caps Lock to Space
    services.keyd = {
      enable = true;
      keyboards.default = {
        ids = [ "*" ];
        settings.main = {
          capslock = "leftshift";
        };
      };
    };

    # TeamViewer remote desktop service
    services.teamviewer.enable = true;

    # OBS Studio with plugins (system-level for proper integration)
    programs.obs-studio = {
      enable = true;
      enableVirtualCamera = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
        obs-composite-blur
      ];
    };

    # Enable Niri wayland compositor
    programs.niri = {
      enable = true;
    };

    # DankMaterialShell - system-level installation
    programs.dank-material-shell = {
      enable = true;

      # Systemd service disabled - DMS is spawned by Niri instead
      systemd = {
        enable = false;
      };

      # Core features
      # enableSystemMonitoring requires dgop package which is not available
      enableSystemMonitoring = false;
      enableVPN = true; # VPN management widget
      enableDynamicTheming = true; # Wallpaper-based theming (matugen)
      enableAudioWavelength = true; # Audio visualizer (cava)
      enableCalendarEvents = false; # Calendar integration (khal) - disabled: khal broken upstream
      # Note: enableClipboard, enableColorPicker, enableBrightnessControl, enableSystemSound
      # are now built-in to DMS and no longer need to be specified
    };

    # XDG Desktop Portal - following niri's recommended configuration
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gnome
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
        kdePackages.xdg-desktop-portal-kde
      ];
      config.common = {
        default = [
          "gnome"
          "gtk"
        ];
        "org.freedesktop.impl.portal.Access" = [ "gtk" ];
        "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "kde" ];
        # Secret Service handled by KeePassXC (not via portal)
      };
    };
  };
}
