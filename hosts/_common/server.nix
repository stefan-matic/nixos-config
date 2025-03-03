{ config, pkgs, inputs, userSettings, systemSettings, ... }:

{
  imports =
    [
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
    defaultSession = "plasma";
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
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "dialout" "docker"];
    packages = with pkgs; [
      kdePackages.kate
      vscode
    ];
  };

  programs.firefox.enable = true;
  programs.kdeconnect.enable = true;
  programs.zsh.enable = true;

  # Disabled cause conflict with gnupg agent with ssh support
  #programs.ssh.startAgent = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  #environment.systemPackages = with pkgs; let themes = pkgs.callPackage ../../nixpkgs/pkgs/sddm-theme.nix {}; in [
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    git
  ];

  fonts.packages = with pkgs; [
    font-awesome
    fira-code
    fira-code-symbols
    #(nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    nerdfonts
    powerline-fonts
    powerline-symbols
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
  };
}
