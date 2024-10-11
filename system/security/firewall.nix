{ ... }:

{
  # Firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22000 21027 # syncthing
    ];
    allowedTCPPortRanges = [
      { from = 1714; to = 1764; } #kdeconnect
    ];
    allowedUDPPorts = [
      22000 21027 # syncthing
    ];
    allowedUDPPortRanges = [
      { from = 1714; to = 1764; } #kdeconnect
    ];
  };
}