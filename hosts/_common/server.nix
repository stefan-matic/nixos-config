{ config, pkgs, lib, ... }:

{
  imports =
    [
      ./default.nix
      ../../system/security/firewall.nix
      ../../system/app/docker.nix
    ];

  config = {
    # Bootloader configuration
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Docker configuration
    docker.storageDriver = "overlay2";

    # Networking configuration
    networking = {
      hostName = config.systemSettings.hostname;
      networkmanager.enable = true;
    };

    # Time and locale settings
    time.timeZone = "Europe/Sarajevo";
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

    # Desktop environment configuration
    services.desktopManager.plasma6.enable = true;
    services.displayManager = {
      defaultSession = "plasma";
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };

    # X11 configuration
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    # System services
    services = {
      printing.enable = true;
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };
    };

    services.pulseaudio.enable = false;
    security.rtkit.enable = true;

    # User configuration
    users.users.${config.userSettings.username} = {
      isNormalUser = true;
      description = config.userSettings.name;
      shell = pkgs.zsh;
      extraGroups = [ "networkmanager" "wheel" "dialout" "docker" ];
      packages = with pkgs; [
        kdePackages.kate
        vscode
      ];
    };

    # Program configuration
    programs = {
      firefox.enable = true;
      #kdeconnect.enable = true;
      zsh.enable = true;
    };

    # Package configuration
    nixpkgs.config.allowUnfree = true;
    environment.systemPackages = with pkgs; [
      git
    ];

    # Font configuration
    fonts.packages = with pkgs; [
      font-awesome
      fira-code
      fira-code-symbols
      powerline-fonts
      powerline-symbols
      nerd-fonts.jetbrains-mono
    ];

    # System version
    system.stateVersion = "24.11";

    # Module arguments
    _module.args = {
      inherit (config) userSettings;
    };
  };
}
