{ ... }:

{
  # Firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22000 21027 # syncthing
    ];
    allowedUDPPorts = [
      22000 21027 # syncthing
    ];

    allowedTCPPortRanges = [
      { from = 1714; to = 1764; } # KDE Connect
    ];
    allowedUDPPortRanges = [
      { from = 1714; to = 1764; } # KDE Connect
    ];
  };
}