{ config, pkgs, ... }:

let
  # Viber's bundled libxml2 has no versioned symbols, but its Qt6WebEngineCore
  # hard-links the legacy `valuePush@LIBXML2_2.4.30` alias. libxml2 >= 2.14
  # dropped that alias, so nixpkgs' current libxml2 (2.15.x) makes Viber fail
  # with "undefined symbol: valuePush". Pin 2.13.8, which still exports it.
  libxml2-legacy = pkgs.libxml2.overrideAttrs (old: rec {
    version = "2.13.8";
    src = pkgs.fetchurl {
      url = "mirror://gnome/sources/libxml2/2.13/libxml2-${version}.tar.xz";
      hash = "sha256-J3KUyzMRmrcbK8gfL0Rem8lDW4k60VuyzSsOhZoO6Eo=";
    };
    # nixpkgs' 2.15 patch set doesn't apply to the 2.13 tree (CVE-2026-11979
    # touches test/catalogs/test.sh, absent here). That CVE is in the
    # `xmlcatalog --shell` CLI parser, not the library; only the `out` (lib)
    # output is consumed below, so the CLI never lands in any profile.
    patches = [ ];
  });

  # Create custom desktop file with correct Icon and StartupWMClass
  viberDesktopFile = pkgs.writeTextDir "share/applications/viber.desktop" ''
    [Desktop Entry]
    Name=Viber
    Comment=Viber VoIP and messenger
    Exec=viber %u
    Icon=ViberPC
    Terminal=false
    Type=Application
    Categories=Network;InstantMessaging;P2P;
    MimeType=x-scheme-handler/viber;
    StartupWMClass=ViberPC
  '';

  # Create a wrapped version of Viber with fixed icons and Wayland support
  viber-fixed = pkgs.symlinkJoin {
    name = "viber-fixed";
    paths = [
      viberDesktopFile
      pkgs.viber
    ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      # nixpkgs' viber launcher hardcodes QT_QPA_PLATFORM=xcb, and post-Qt6-bump
      # the xcb plugin needs libxcb-cursor which isn't shipped -> crash. Bypass
      # that launcher and wrap the real binary directly, forcing Wayland.
      rm $out/bin/viber
      makeWrapper ${pkgs.viber}/opt/viber/Viber $out/bin/viber \
        --prefix LD_LIBRARY_PATH : "${libxml2-legacy.out}/lib:${pkgs.libxshmfence}/lib" \
        --set QT_QPA_PLATFORM wayland \
        --set QT_PLUGIN_PATH "${pkgs.viber}/opt/viber/plugins" \
        --set QML2_IMPORT_PATH "${pkgs.viber}/opt/viber/qml"

      # Create icon symlinks with correct app-id (ViberPC) for DMS
      mkdir -p $out/share/icons/hicolor/{scalable,48x48,64x64,128x128,256x256}/apps
      mkdir -p $out/share/pixmaps

      ln -sf ${pkgs.viber}/share/icons/hicolor/scalable/apps/Viber.svg \
        $out/share/icons/hicolor/scalable/apps/ViberPC.svg
      ln -sf ${pkgs.viber}/share/viber/48x48.png \
        $out/share/icons/hicolor/48x48/apps/ViberPC.png
      ln -sf ${pkgs.viber}/share/viber/64x64.png \
        $out/share/icons/hicolor/64x64/apps/ViberPC.png
      ln -sf ${pkgs.viber}/share/viber/128x128.png \
        $out/share/icons/hicolor/128x128/apps/ViberPC.png
      ln -sf ${pkgs.viber}/share/viber/256x256.png \
        $out/share/icons/hicolor/256x256/apps/ViberPC.png
      ln -sf ${pkgs.viber}/share/pixmaps/viber.png \
        $out/share/pixmaps/ViberPC.png
    '';
  };
in
{
  home.packages = [ viber-fixed ];
}
