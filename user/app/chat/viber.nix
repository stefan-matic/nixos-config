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

  # Create a wrapped version of Viber with the correct libxml2
  viber-fixed = pkgs.symlinkJoin {
    name = "viber-fixed";
    paths = [ pkgs.viber ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/viber \
        --prefix LD_LIBRARY_PATH : "${libxml2-compat.out}/lib"
    '';
  };
in
{
  home.packages = [ viber-fixed libxml2-compat ];
}
