{ config, ... }:

{
  # Firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22000
      21027 # syncthing
      3389 # RDP
    ];
    allowedUDPPorts = [
      22000
      21027 # syncthing
      config.services.tailscale.port
    ];

    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      } # KDE Connect
    ];
    allowedUDPPortRanges = [
      {
        from = 1714;
        to = 1764;
      } # KDE Connect
    ];
  };

  networking.firewall.checkReversePath = "loose"; # NordVPN needs this, check if we can skip it or smth
}
