#{ config, pkgs, lib, ... }:

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
  imports =
    [
      ./default.nix
      ../../system/app/k3s.nix
    ];

  config = {

    environment.systemPackages = with pkgs; [

    ];

    services.openssh = {
      enable = true;
      settings.PermitRootLogin = "no";
      allowSFTP = true;
    };

    security.pam = {
      services.sudo.sshAgentAuth = true;
      sshAgentAuth = {
        enable = true;
        authorizedKeysFiles = [
          "/etc/ssh/authorized_keys.d/%u"
        ];
      };
    };

    users.users.${config.userSettings.username}.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDJ2jVUL/jANIzKv14MfJN6bNQzYD41BJssTZiDL34sk stefan@matic.ba"
    ];
  };
}
