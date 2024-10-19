# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, systemSettings, userSettings, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ../../system/hardware-configuration.nix
      ../../system/security/firewall.nix
      ../../system/app/virtualization.nix
      ( import ../../system/app/docker.nix {storageDriver = null; inherit pkgs userSettings;} )
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = systemSettings.hostname;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Sarajevo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "bs_BA.UTF-8";
    LC_IDENTIFICATION = "bs_BA.UTF-8";
    LC_MEASUREMENT = "bs_BA.UTF-8";
    LC_MONETARY = "bs_BA.UTF-8";
    LC_NAME = "bs_BA.UTF-8";
    LC_NUMERIC = "bs_BA.UTF-8";
    LC_PAPER = "bs_BA.UTF-8";
    LC_TELEPHONE = "bs_BA.UTF-8";
    LC_TIME = "bs_BA.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  #services.xserver.enable = true;
  #services.xserver.displayManager.sddm.wayland.enable = true;

  services.desktopManager.plasma6.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager = {
    defaultSession = "hyprland";
    sddm = {
      #package = pkgs.kdePackages.sddm;
      enable = true;
      wayland.enable = true;
      #theme = "sddm-astronaut";
      #extraPackages = [ pkgs.sddm-astronaut ];

      #enableHidpi = true;
      #theme = "sugar-dark";
      #theme = "${import ../../themes/sddm-theme.nix { inherit pkgs; }}";
      #theme = "maya";
    };
  };

  ## SHOULD BE WORKING EXAMPLE
  # enable SDDM & the KDE Plasma Desktop Environment with Wayland
  # services.desktopManager.plasma6.enable = true;
  # services.displayManager.sddm = {
  #   enable = true;
  #   wayland.enable = true;
  #   theme = "sddm-astronaut-theme";
  #   extraPackages = [ pkgs.sddm-astronaut ];
  # };


  #TODO: Check if this is working
  #services.libinput.touchpad.naturalScrolling = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.cloudflare-warp.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${userSettings.username} = {
    isNormalUser = true;
    description = userSettings.name;
    extraGroups = [ "networkmanager" "wheel" "dialout" "docker"];
    packages = with pkgs; [
      kdePackages.kate

    #  thunderbird
      #viber
      stefan
    ];
  };

  programs.firefox.enable = true;
  programs.kdeconnect.enable = true;
  programs.ssh.startAgent = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  #environment.systemPackages = with pkgs; let themes = pkgs.callPackage ../../nixpkgs/pkgs/sddm-theme.nix {}; in [
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    
    git
    waybar
    swaynotificationcenter
    #might be needed for sway
    libnotify
    nixpkgs-fmt

    #TODO: check if this is proper to activate here
    rofi-wayland

    networkmanagerapplet

    hyprpaper

    # Stvari za sddm teme
    #sddm-kcm
    #themes.sddm-sugar-dark 

    # Alt tab
    inputs.hyprswitch.packages.x86_64-linux.default

    #TODO: test za SDDM theme
    #libsforqt5.qt5.qtquickcontrols2   
    #libsforqt5.qt5.qtgraphicaleffects
    #sddm-astronaut

    cloudflare-warp
  ];

  fonts.packages = with pkgs; [
    font-awesome
    fira-code
    fira-code-symbols
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    powerline-fonts
    powerline-symbols
  ];

  #HYPRLAND
  programs.hyprland = {
    enable = true;
    # set the flake package
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    # make sure to also set the portal package, so that they are in sync
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  #TODO: #check if this is proper to activate here
  security.pam.services.hyprlock = {};

  security.pam.services.sddm.enableKwallet = true;

  #hardware.opengl = {
  #  package = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.mesa.drivers;

  #  # if you also want 32-bit support (e.g for Steam)
  #  driSupport32Bit = true;
  #  package32 = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.pkgsi686Linux.mesa.drivers;
  #};

  # interactions between windows (links, screenshare, etc)
  # xdg.portal = {
  #   enable = true;
  #   extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  # };


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
  
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };
}
