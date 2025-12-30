{ pkgs }:

{
  systemSettings = {
    hostname = "stefan-nix-live";
    host = "stefan-nix-live";
    timezone = "Europe/Sarajevo";
    locale = "en_US.UTF-8";
    # Locale settings: English with dd-mm-yyyy date format
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_GB.UTF-8";  # Use British English for dd-mm-yyyy format
    };
  };

  userSettings = {
    username = "stefan";
    name = "stefan";
    email = "stefan@matic.ba";
    theme = "dracula";
    term = "alacritty";
    font = "Intel One Mono";
    fontPkg = pkgs.intel-one-mono;
    editor = "nano";
  };
}
