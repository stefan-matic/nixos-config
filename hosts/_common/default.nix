# Common configuration for all hosts
{
  lib,
  inputs,
  outputs,
  config,
  pkgs,
  userSettings,
  systemSettings,
  ...
}: {
  imports =
    [
      ../../system/security/firewall.nix
      ../../system/app/docker.nix
    ];

  config = {
    # Time and locale settings
    time.timeZone = systemSettings.timezone;
    i18n.defaultLocale = systemSettings.locale;
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

    # Networking configuration
    networking = {
      hostName = config.systemSettings.hostname;
      networkmanager.enable = true;
    };

    # Docker configuration
    docker.storageDriver = "overlay2";

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

    # Program configuration
    programs = {
      firefox.enable = true;
      #kdeconnect.enable = true; #use home manager instead
      zsh.enable = true;
    };

    # Package configuration
    environment.systemPackages = with pkgs; [
      git
      dig
      wget
      openssl
      kdePackages.kcalc
      inetutils
    ];

    # Font configuration
    fonts.packages = with pkgs; [
      font-awesome
      fira-code
      fira-code-symbols
      powerline-fonts
      powerline-symbols
      nerd-fonts.jetbrains-mono
      nerd-fonts.overpass
    ];

    # Module arguments
    _module.args = {
      inherit (config) userSettings;
    };

    # User configuration
    users.users.${config.userSettings.username} = {
      isNormalUser = true;
      description = config.userSettings.name;
      shell = pkgs.zsh;
      extraGroups = [ "networkmanager" "wheel" "dialout" "docker" "nordvpn" ];
      packages = with pkgs; [
        (pkgs.writeShellScriptBin "code" ''
          exec ${vscode}/bin/code --disable-gpu "$@"
        '')
        vscode
        #stable.rustdesk
      ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDFuv+jzJgJ9hsmEczKo1iSO4NeKthMRJfme+w7rQJlQGGHDJE/yJMeIvZUKuXeR5SeH8E3oTIHW0PVjFYAO+GI9kubakseI9KekMqf9hgFaafyh8TEb4NLTvEzs6l6surZfMI6wK6U5JhJG8bnZSuhCnvg3+qhqLCB9aMKikz5Z5+gH8wMZVno0jXvvT8uV8DQTAoCxobWU/gB+aHCMPevrn0rbmSCS5qEQsuieWmZEKnmnv5eeZ/QU2fd+QZ9xOusJeJFGrvgGN/cpg9y2SqAmhmaLgC0U9WhqOZHd/fBjnMs7CKrWnVpPy4yXPlLqBuJpAuK0t+aPjEfYP+GS6aYYNzOzjd/3q9m3NitQTDFBI20cXi+TpY+vJMaMRCrkcVHBM+k9pgNXjg/OD7a4vqwxpvAKzaR1bPhyEgGKI5fgNbs5jecPre6JvueIbjmez9hgSkiYY9D5iL1AYlVqoTy/08KS6ojNzLRpBKZfiKf53vsJZWzd5qdsRsbZnddKDPi4aQtAwpDJL9/oPKNefNRh4vG0NZGfrpsi1tvcxEAZf5Z8P/p2mCyulQeWdP0mALDm+B+Ko2qZeltPIk0jDk0oeKxMEgZEJt1skZk2ge552ubOz2nlvTBRvEcnALpeFDf+9lIbKFMJDXEili1frZ1c04IDEBe2SM4C+PE4NxZxw== stefanmatic@Mk-IV"
      ];
    };

    users.groups.nordvpn = {};

    # System version
    system.stateVersion = "24.11";

    # Moved nixpkgs config here
    nixpkgs = {
      overlays = [
        outputs.overlays.additions
        outputs.overlays.modifications
        outputs.overlays.unstable-packages
      ];
      config = {
        allowUnfree = true;
        permittedInsecurePackages = [
          "electron-35.7.5"
        ];
      };
    };

    # Moved nix config here
    nix = {
      settings = {
        experimental-features = "nix-command flakes";
        trusted-users = [ "root" "stefanmatic" "fallen" ];
      };
      gc = {
        automatic = true;
        options = "--delete-older-than 30d";
      };
      optimise.automatic = true;
    };
  };
}
