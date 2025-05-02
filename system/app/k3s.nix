{ config, pkgs, lib, ... }:

{
  services.k3s = {
      enable = true;
      role = "server";
      #serverAddr = "192.168.1.100";
      #serverPort = 6443;
      #token = "token";
    };

  networking.firewall = {
      enable = true;
      allowedTCPPorts = [
        6443 # k3s
      ];
    };
}
