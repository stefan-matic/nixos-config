{ pkgs, ... }:

{
  # ZVIJER-specific system packages
  # Hardware-specific tools and system utilities unique to this host
  #
  # NOTE: select-browser has been moved to hosts/_common/client.nix (used by all hosts)

  environment.systemPackages = with pkgs; [
    # KDE utilities (ZVIJER uses KDE desktop)
    kdePackages.kdialog

    # Razer hardware support (system-wide daemon needed)
    openrazer-daemon
    razergenie
  ];
}
