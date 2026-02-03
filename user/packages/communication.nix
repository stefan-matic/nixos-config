{ pkgs, ... }:

{
  # Communication and collaboration apps

  home.packages = with pkgs; [
    # Chat & Messaging
    # Enable PipeWire screen capture for Slack (fixes frozen screen sharing under Wayland)
    (symlinkJoin {
      name = "slack";
      paths = [ unstable.slack ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/slack \
          --add-flags "--enable-features=UseOzonePlatform,WebRTCPipeWireCapturer" \
          --add-flags "--ozone-platform=wayland"
      '';
    })
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
