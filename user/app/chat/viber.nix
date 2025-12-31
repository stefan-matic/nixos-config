{ config, pkgs, ... }:

let
  # Use libxml2 version that provides libxml2.so.2
  libxml2-compat = pkgs.libxml2.overrideAttrs (oldAttrs: rec {
    version = "2.13.8";
    src = pkgs.fetchurl {
      url = "https://download.gnome.org/sources/libxml2/${pkgs.lib.versions.majorMinor version}/libxml2-${version}.tar.xz";
      hash = "sha256-J3KUyzMRmrcbK8gfL0Rem8lDW4k60VuyzSsOhZoO6Eo=";
    };
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

  # Create a wrapped version of Viber with the correct libxml2 and fixed icons
  viber-fixed = pkgs.symlinkJoin {
    name = "viber-fixed";
    paths = [ viberDesktopFile pkgs.viber ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/viber \
        --prefix LD_LIBRARY_PATH : "${libxml2-compat.out}/lib"

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
