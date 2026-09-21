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

  # Touch ID for sudo. The macOS analogue of the YubiKey PAM touch-to-sudo
  # setup in system/security/yubikey.nix -- sudo_local survives OS updates,
  # unlike editing /etc/pam.d/sudo directly.
  security.pam.services.sudo_local = {
    touchIdAuth = true;

    # pam_tid alone does NOT work inside tmux: the tmux server is detached
    # from the user's GUI bootstrap session, so the Touch ID prompt has no
    # session to draw into and sudo silently falls back to a password.
    # Ghostty launches straight into tmux (user/app/terminal/ghostty.nix),
    # so effectively every sudo would miss the sensor without this.
    # pam_reattach re-attaches the process to that session first; nix-darwin
    # orders it before pam_tid, which is required.
    reattach = true;
  };

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

      # Paneru does window management and Raycast is the launcher, so the Dock
      # is decoration. Empty it and strip its animations.
      persistent-apps = [ ];
      persistent-others = [ ];
      launchanim = false;
      expose-animation-duration = 0.1;
      mineffect = "scale";
      # Disable hot corners
      wvous-tl-corner = 1;
      wvous-tr-corner = 1;
      wvous-bl-corner = 1;
      wvous-br-corner = 1;
    };

    # Finder, tuned to behave as much like KDE Dolphin as its settings allow.
    # The remaining differences (Enter renames instead of opening, Delete does
    # not delete, no dual pane, no editable address bar) are hardcoded in
    # Finder and cannot be changed here -- see docs/macos-setup.md.
    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true; # show dotfiles
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "Nlsv"; # List view, like Dolphin's details view
      ShowPathbar = true; # breadcrumb bar at the bottom
      ShowStatusBar = true; # item count + free space
      _FXShowPosixPathInTitle = true; # real path, not just the leaf name

      # Directories before files, the single biggest Dolphin-vs-Finder
      # difference in day-to-day use.
      _FXSortFoldersFirst = true;
      _FXSortFoldersFirstOnDesktop = true;

      # Search the folder you are in, not the whole Mac. Finder's default
      # ("This Mac") is the other big everyday annoyance.
      FXDefaultSearchScope = "SCcf";

      # New windows open in home rather than Recents.
      NewWindowTarget = "Home";

      # Let Finder actually be quit (cmd-Q), like any other file manager.
      QuitMenuItem = true;

      ShowExternalHardDrivesOnDesktop = true;
      ShowRemovableMediaOnDesktop = true;
      ShowMountedServersOnDesktop = true;
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
      NSTableViewDefaultSizeMode = 1; # Compact list rows, denser like Dolphin
      AppleShowScrollBars = "Always"; # Linux-style persistent scrollbars

      # === Coming from linux/KDE/niri ===

      # Tab reaches every control in a dialog, not just text fields. macOS
      # defaults to text-fields-only, which makes dialogs unusable by keyboard.
      AppleKeyboardUIMode = 3;

      # F1-F12 are real function keys, not brightness/volume media keys.
      # Also what makes the F2-to-rename Finder binding work.
      "com.apple.keyboard.fnState" = true;

      # ctrl+cmd+drag moves a window from anywhere in it, not just the title
      # bar -- the closest macOS gets to niri's Mod+drag.
      NSWindowShouldDragOnGesture = true;

      # Don't yank the display to another Space when an app is activated.
      # Essential with paneru's virtual workspaces, otherwise clicking a Dock
      # icon teleports you off the workspace you are working on.
      AppleSpacesSwitchOnActivate = false;

      # Kill window open/close animations. A tiling WM should feel instant.
      NSAutomaticWindowAnimationsEnabled = false;

      # Save dialogs default to the filesystem, not iCloud Drive.
      NSDocumentSaveNewDocumentsToCloud = false;
      _HIHideMenuBar = false;
      # Natural scrolling, matching `natural-scroll` in the niri touchpad
      # block (user/wm/niri/common.nix). Caveat: macOS has ONE global scroll
      # direction, so this flips an external mouse too -- niri sets it for
      # the touchpad only. LinearMouse can split them per-device if that
      # becomes annoying with a desk mouse.
      "com.apple.swipescrolldirection" = true;
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

  # Domains without a dedicated nix-darwin option.
  system.defaults.CustomUserPreferences = {
    # Don't scatter .DS_Store files over network shares and USB sticks --
    # they show up as junk on the linux/unraid side of a shared folder.
    "com.apple.desktopservices" = {
      DSDontWriteNetworkStores = true;
      DSDontWriteUSBStores = true;
    };

    # Hand the four-finger swipes to paneru (see user/wm/paneru/common.nix).
    # macOS binds them to Spaces/Mission Control by default, which is
    # redundant once paneru owns virtual workspaces. Three-finger gestures
    # are left alone because TrackpadThreeFingerDrag below uses them.
    "com.apple.AppleMultitouchTrackpad" = {
      TrackpadFourFingerHorizSwipeGesture = 0;
      TrackpadFourFingerVertSwipeGesture = 0;
    };
    "com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
      TrackpadFourFingerHorizSwipeGesture = 0;
      TrackpadFourFingerVertSwipeGesture = 0;
    };

    # Shottr's capture hotkeys. It uses the same KeyboardShortcuts library
    # as Maccy, storing each binding as a JSON string of Carbon codes.
    #   carbonKeyCode:   x=7  (a=0 s=1 d=2 ... z=6 x=7 c=8 v=9)
    #   carbonModifiers: cmd=256 shift=512 option=2048 control=4096
    #   so ctrl+shift = 4608, matching niri's Ctrl+Shift+X screenshot bind.
    # Decoding verified against the defaults Shottr had already written:
    # area was {19,768} = cmd+shift+2, ocr {31,6400} = ctrl+opt+cmd+o.
    #
    # Quit Shottr before a switch, or it rewrites these from memory on exit.
    "cc.ffitch.shottr" = {
      KeyboardShortcuts_area = ''{"carbonKeyCode":7,"carbonModifiers":4608}'';
    };

    # Free ctrl+arrows so they can be word motion (user/app/keybindings.nix)
    # instead of switching Spaces. 79/80 are move-left/right-a-space and
    # 81/82 their shift variants. paneru owns workspaces here, so macOS
    # Spaces switching is redundant anyway.
    "com.apple.symbolichotkeys" = {
      AppleSymbolicHotKeys = {
        "79" = {
          enabled = false;
        };
        "80" = {
          enabled = false;
        };
        "81" = {
          enabled = false;
        };
        "82" = {
          enabled = false;
        };
      };
    };
  };

  # Keyboard, mapped onto the linux hosts' physical layout.
  #
  # A MacBook's bottom row is  fn | control | option | command | space
  # and a ThinkPad's is        Fn | Ctrl    | Super  | Alt     | space
  # so positionally option IS Super and command IS Alt. That is why paneru
  # uses `alt` as Mod (user/wm/paneru/common.nix): it already sits where
  # Super does on the linux machines. Swapping Mod onto cmd in the config
  # would collide with 30 of the 70 chords -- cmd-c, cmd-q, cmd-tab, cmd-f,
  # cmd-s, cmd-1..5 among them -- so it is done by key swap, never in config.
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
    # Ctrl into the bottom-left corner, as on the linux keyboards.
    swapLeftCtrlAndFn = true;
  };

  system.stateVersion = 6;
}
