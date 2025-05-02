{ inputs, ... }: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev:
    {
      # Import Prusa Slicer overlay
      prusa-slicer = import ./prusa-slicer {
        inherit (prev) stdenv lib binutils fetchFromGitHub fetchpatch cmake pkg-config python3
          wrapGAppsHook3 boost cereal cgal curl darwin dbus eigen expat glew glib glib-networking
          gmp gtk3 hicolor-icon-theme ilmbase libpng mpfr nanosvg nlopt opencascade-occt_7_6_1
          openvdb pcre qhull tbb_2021_11 wxGTK32 xorg libbgcode heatshrink catch2_3 webkitgtk_4_0 z3
          systemd;
      };
    };

    # Simplified unstable packages overlay
    unstable-packages = final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        inherit (prev) system;
        config.allowUnfree = true;
      };
    };

    stable-packages = final: prev: {
      stable = import inputs.nixpkgs-stable {
        inherit (prev) system;
        config.allowUnfree = true;
      };
    };
}

