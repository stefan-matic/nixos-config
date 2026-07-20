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
          --add-flags "--ozone-platform=wayland" \
          --add-flags "--disable-gpu-compositing"
      '';
    })
    discord
    element-desktop
    # Remote Desktop
    remmina
    # 1.4.6 vendor-staging FOD (rustdesk wezterm submodule fetch via
    # fetch-cargo-vendor-util-v2) fails with exit 123; not cached. Stable's
    # 1.4.3 vendor is cached, so it skips the broken git fetch entirely.
    stable.rustdesk

    thunderbird
  ];
}
