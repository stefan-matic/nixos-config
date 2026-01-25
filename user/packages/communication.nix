{ pkgs, ... }:

{
  # Communication and collaboration apps

  home.packages = with pkgs; [
    # Chat & Messaging
    slack
    discord
    element-desktop

    # Video Conferencing
    zoom-us

    # Remote Desktop
    remmina
    rustdesk

    thunderbird
  ];
}
