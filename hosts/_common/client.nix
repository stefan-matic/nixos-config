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
    ./default.nix
    # Home-manager as NixOS module for single-command deployment
    inputs.home-manager.nixosModules.home-manager
    ../../system/app/virtualization.nix
    ../../system/bluetooth.nix
    ../../system/packages/desktop.nix
    ./prefetch.nix
    # DMS greeter (greetd) — replaces SDDM on all client hosts
    inputs.dms.nixosModules.greeter
  ];

  # Home-manager base configuration (user-specific config in each host)
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup"; # Backup existing files instead of failing
    extraSpecialArgs = {
      inherit inputs outputs;
      userSettings = config.userSettings;
    };
    # Note: home-manager.users.<name> is configured per-host in each configuration.nix
  };

  # Desktop environment configuration
  services.desktopManager.plasma6.enable = true;

  # Qt theming - ensures KDE apps (Dolphin, Kate, etc.) respect dark theme
  # under non-Plasma sessions like niri. Installs plasma-integration so
  # QT_QPA_PLATFORMTHEME=kde resolves correctly.
  qt = {
    enable = true;
    platformTheme = "kde";
    style = "breeze";
  };

  services.gnome.gnome-keyring.enable = false;
  services.displayManager.defaultSession = "niri";

  # DMS greeter (greetd) replaces SDDM. greetd handles login via the same
  # Niri+DMS stack used in the session. Wallpaper + theme are copied from
  # configHome on each greetd preStart.
  programs.dank-material-shell.greeter = {
    enable = true;
    compositor.name = "niri";
    compositor.customConfig = builtins.readFile ../../user/wm/dms/greeter-niri.kdl;
    configHome = "/home/${config.userSettings.username}";
  };

  # User must be in `greeter` group for `dms greeter sync` and status checks.
  users.users.${config.userSettings.username}.extraGroups = [ "greeter" ];

  # NixOS greetd module passes --config from /nix/store directly; mirror it
  # at /etc/greetd/config.toml so `dms greeter status` can detect the install.
  environment.etc."greetd/config.toml".source =
    (pkgs.formats.toml { }).generate "greetd.toml"
      config.services.greetd.settings;

  # Pre-create XDG subdirs that `dms greeter status` expects.
  systemd.tmpfiles.settings."20-dms-greeter-xdg" = {
    "/var/lib/dms-greeter/.local/state".d = {
      user = "greeter";
      group = "greeter";
      mode = "0755";
    };
    "/var/lib/dms-greeter/.local/share".d = {
      user = "greeter";
      group = "greeter";
      mode = "0755";
    };
    "/var/lib/dms-greeter/.cache".d = {
      user = "greeter";
      group = "greeter";
      mode = "0755";
    };
  };

  # Pre-seed greeter memory so username pre-fills on first boot. Subsequent
  # logins auto-update memory.json via DMS itself.
  systemd.services.greetd.preStart = lib.mkAfter ''
    state_dir="/var/lib/dms-greeter/.local/state"
    mkdir -p "$state_dir"
    if [ ! -f "$state_dir/memory.json" ]; then
      echo '{"lastSuccessfulUser":"${config.userSettings.username}"}' > "$state_dir/memory.json"
      chown -R greeter:greeter /var/lib/dms-greeter/.local || true
    fi
  '';

  # X11 configuration
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  environment.systemPackages =
    with pkgs;
    let
      customPkgs = import ../../pkgs { inherit pkgs; };
    in
    [
      # Essential system utilities
      (unstable.google-chrome.override { commandLineArgs = [ "--disable-print-preview" ]; }) # System print dialog

      # Custom packages (common to all client hosts)
      customPkgs.select-browser # Browser selection utility

      # Yubikey support
      yubioath-flutter
      pcsclite

      # Barcode/QR utilities (system-wide)
      zbar

      # Nix utilities
      nix-prefetch-git
      nix-prefetch-github

      # Boot/OS tools
      os-prober # For dual-boot detection

      # Android device tools (ADB for scrcpy)
      android-tools

      wl-mirror

      nixfmt

      # VPN tools
      wireguard-tools # WireGuard VPN support for NetworkManager

      ssh-to-age # Convert SSH keys to age keys

      openvpn

    ];

  # Enable Niri wayland compositor with XWayland support
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  # XDG Desktop Portal configuration
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome # Primary portal implementation (ScreenCast for niri)
      xdg-desktop-portal-gtk # GTK file chooser (fallback)
      kdePackages.xdg-desktop-portal-kde # KDE portal for Dolphin and other KDE apps
    ];
    config = {
      common = {
        default = [
          "gnome"
          "gtk"
        ];
        "org.freedesktop.impl.portal.Access" = [ "gtk" ];
        "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
      };
      niri = {
        default = [
          "gnome"
          "gtk"
        ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
        "org.freedesktop.impl.portal.Access" = [ "gtk" ];
        "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "kde" ];
      };
      # KDE apps (Dolphin, Kate, etc.) should use the KDE portal
      KDE = {
        default = [
          "kde"
          "gtk"
        ];
        "org.freedesktop.impl.portal.AppChooser" = [ "kde" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "kde" ];
      };
    };
  };

  # Yubico Authenticator
  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = false;
    # Use pinentry-gnome3 which uses libsecret to query Secret Service (KeePassXC)
    pinentryPackage = pkgs.pinentry-gnome3;
  };

  # SSH agent - disabled when Niri is enabled (Niri uses GNOME keyring gcr-ssh-agent)
  programs.ssh.startAgent = lib.mkDefault (!config.programs.niri.enable);

  # Enable nix-ld for running generic Linux binaries (e.g. OpenDeck plugins)
  programs.nix-ld.enable = true;

  # Add udev rules for Arduino permissions
  services.udev.extraRules = ''
    # Arduino permissions
    SUBSYSTEM=="tty", ATTRS{idVendor}=="2341", ATTRS{idProduct}=="0043", MODE="0666", GROUP="dialout", SYMLINK+="arduino"
  '';

  # Wipe ~/Workspace/volatile at boot so scratchpad projects always start clean.
  # R! removes recursively at boot only; d recreates the empty directory.
  systemd.tmpfiles.rules = [
    "R! /home/${config.userSettings.username}/Workspace/volatile - - - - -"
    "d /home/${config.userSettings.username}/Workspace/volatile 0755 ${config.userSettings.username} users - -"
  ];
}
