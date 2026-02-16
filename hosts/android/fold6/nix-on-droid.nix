# Nix-on-Droid configuration for Samsung Galaxy Fold 6
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Set your time zone
  time.timeZone = "Europe/Belgrade";

  # Configure Nix
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Terminal configuration
  terminal.font = "${(pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; })}/share/fonts/truetype/NerdFonts/FiraCodeNerdFont-Regular.ttf";

  # System packages available in the nix-on-droid environment
  environment.packages = with pkgs; [
    # Essential tools
    git
    vim
    wget
    curl
    openssh

    # Modern CLI tools
    bat
    lsd
    fd
    ripgrep
    fzf
    jq
    yq-go

    # Shell enhancements
    zoxide
    starship

    # Development
    lazygit
    delta

    # Documentation
    tldr
    glow

    # Core utilities
    coreutils
    findutils
    diffutils
    gnugrep
    gnused
    gawk
    gnutar
    gzip
    bzip2
    xz
    unzip
    zip
    procps
    utillinux
    hostname

    # Utilities
    htop
    tree
    ncdu

    # Python (for udocker via venv)
    python3
  ];

  # Home-manager integration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-bak";

    config = import ../../../home/android.nix;
  };

  # Set up environment variables
  environment.etcBackupExtension = ".bak";

  # Nix-on-Droid state version
  system.stateVersion = "24.05";

  # Enable a basic shell
  user.shell = "${pkgs.zsh}/bin/zsh";
}
