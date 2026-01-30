{ pkgs }:

{
  systemSettings = {
    system = "x86_64-linux";
    hostname = "z420";
    host = "z420";
    timezone = "Europe/Sarajevo";
    locale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_GB.UTF-8"; # dd-mm-yyyy format
    };
  };

  userSettings = {
    username = "sysmatic";
    name = "SysMatic";
    email = "stefan@matic.ba";
    editor = "nano";
  };
}
