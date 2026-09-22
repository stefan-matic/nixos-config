# Common configuration for all Darwin (macOS) hosts.
#
# Darwin analogue of hosts/_common/default.nix + hosts/_common/client.nix.
# It cannot import either of those: they pull in NixOS-only modules (udev,
# networkmanager, systemd, niri, plasma). What it does reproduce is the parts
# that are policy rather than platform -- nix settings, the overlay stack, GC,
# fonts, and home-manager wiring.
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
    # Home-manager as darwin module for single-command deployment
    inputs.home-manager.darwinModules.home-manager
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

  # macOS resolves the primary user for user-scoped system.defaults and for
  # homebrew activation.
  system.primaryUser = config.userSettings.username;

  users.users.${config.userSettings.username} = {
    name = config.userSettings.username;
    home = "/Users/${config.userSettings.username}";
  };

  # zsh is the login shell; nix-darwin needs this to source /etc/zshrc and put
  # the nix profile on PATH for login shells.
  programs.zsh.enable = true;

  # Touch ID for sudo. This is the macOS analogue of the YubiKey PAM touch-to-
  # sudo setup in system/security/yubikey.nix -- sudo_local survives OS
  # updates, unlike editing /etc/pam.d/sudo directly.
  security.pam.services.sudo_local.touchIdAuth = true;

  # Fonts. Subset of the NixOS list: the nerd fonts the terminal and tmux
  # status glyphs need, minus the linux-desktop-only ones (powerline-symbols,
  # font-awesome for waybar).
  fonts.packages = with pkgs; [
    fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.overpass
    intel-one-mono
    noto-fonts-color-emoji
  ];

  time.timeZone = systemSettings.timezone;

  # Same overlay stack as NixOS, minus the two that only exist to serve linux
  # GUI packages: `nur` (firefox-addons) and `claude-desktop` (debian build).
  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
      outputs.overlays.stable-packages
      outputs.overlays.fast-track-packages
      outputs.overlays.bleeding-edge-packages
    ];
    config = {
      allowUnfree = true;
    };
  };

  nix = {
    # nix-darwin refuses to manage the nix installation when the Determinate
    # installer owns it. Flip this to false if you install nix via
    # `determinate-nixd` instead of the upstream installer.
    enable = lib.mkDefault true;

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        config.userSettings.username
      ];
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
    optimise.automatic = true;
  };

  # macOS system defaults. This is the closest analogue to the niri/DMS
  # desktop tuning on the linux hosts -- the window manager itself is paneru
  # (see user/wm/paneru), this is everything around it.
  system.defaults = {
    dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.2;
      show-recents = false;
      static-only = false;
      mru-spaces = false; # Don't reorder spaces - paneru manages workspaces
      tilesize = 42;
      # Disable hot corners
      wvous-tl-corner = 1;
      wvous-tr-corner = 1;
      wvous-bl-corner = 1;
      wvous-br-corner = 1;
    };

    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "Nlsv"; # List view
      ShowPathbar = true;
      ShowStatusBar = true;
      _FXShowPosixPathInTitle = true;
    };

    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark"; # Matches the dracula theme on linux hosts
      ApplePressAndHoldEnabled = false; # Key repeat instead of accent menu
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      AppleShowAllExtensions = true;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSNavPanelExpandedStateForSaveMode = true;
      NSWindowResizeTime = 0.001; # Near-instant, paneru drives resizes
      _HIHideMenuBar = false;
      "com.apple.swipescrolldirection" = false; # Non-natural scrolling
    };

    trackpad = {
      Clicking = true; # Tap to click
      TrackpadThreeFingerDrag = true;
    };

    screencapture = {
      location = "~/Pictures/Screenshots";
      type = "png";
      disable-shadow = true;
    };

    # false = "Displays have separate spaces" stays ON, which paneru requires
    # to move windows between monitors.
    spaces.spans-displays = false;

    LaunchServices.LSQuarantine = false; # No "downloaded from internet" prompts
    WindowManager.EnableStandardClickToShowDesktop = false;
  };

  # Keyboard: Caps Lock -> Control, matching the linux hosts.
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  system.stateVersion = 6;
}
