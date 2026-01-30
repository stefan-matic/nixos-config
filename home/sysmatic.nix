# Server admin user configuration
# Minimal setup for headless server management
{ ... }:

let
  userSettings = {
    username = "sysmatic";
    name = "SysMatic";
    email = "stefan@matic.ba";
    editor = "nano";
  };
in

{
  imports = [
    ./_server.nix
  ];

  _module.args = {
    inherit userSettings;
  };

  home.username = userSettings.username;
  home.homeDirectory = "/home/${userSettings.username}";
}
