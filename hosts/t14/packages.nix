{ pkgs, ... }:

{
  # T14-specific system packages
  # Hardware-specific tools and system utilities unique to this laptop
  #
  # NOTE: Common packages (select-browser, fuzzel, cloudflare-warp) have been
  # moved to hosts/_common/client.nix to follow DRY principle.
  #
  # Add only truly T14-specific packages here (e.g., specific drivers,
  # hardware control utilities unique to this laptop model).

  environment.systemPackages = with pkgs; [
    # WireGuard VPN tools for mobile connectivity
    wireguard-tools
  ];
}
