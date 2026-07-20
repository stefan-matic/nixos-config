{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # openldap-2.6.13 test017-syncreplication-refresh is upstream-flaky and
    # blocks lutris fhsenv build. Skip tests until nixpkgs lands a fix.
    openldap = prev.openldap.overrideAttrs (_: {
      doCheck = false;
    });

    # pipx 1.8.0 test_package_specifier asserts the old "name@url" form, but the
    # newer packaging lib normalizes to "name @ url" (added spaces). Upstream
    # test rot, not a real defect. Skip tests until nixpkgs bumps pipx.
    pipx = prev.pipx.overridePythonAttrs (_: {
      doCheck = false;
    });

    # DaVinci Resolve bundles Qt5 without the Wayland platform plugin, so it
    # aborts in QGuiApplicationPrivate::createPlatformIntegration when
    # QT_QPA_PLATFORM=wayland is inherited from the Niri session. Force xcb
    # (XWayland) for Resolve's own binaries.
    davinci-resolve = prev.davinci-resolve.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ prev.makeWrapper ];
      postFixup = (old.postFixup or "") + ''
        for bin in resolve fusion fuscript; do
          if [ -e "$out/bin/$bin" ]; then
            wrapProgram "$out/bin/$bin" --set QT_QPA_PLATFORM xcb
          fi
        done
      '';
    });
  };

  # Simplified unstable packages overlay
  unstable-packages = final: prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = prev.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };

  stable-packages = final: prev: {
    stable = import inputs.nixpkgs-stable {
      system = prev.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };

  # Fast-track packages - update independently with: nix flake update nixpkgs-fast-track
  # Use for apps where you want the latest daily — auto-updated at login via
  # user/app/fast-track-update.nix
  fast-track-packages = final: prev: {
    fast-track = import inputs.nixpkgs-fast-track {
      system = prev.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };

  # Bleeding-edge packages - tracks nixpkgs master (no Hydra gate). Use
  # sparingly for tools where latest upstream version matters more than build
  # stability (claude-code, opencode, zed-editor). Auto-updated at login via
  # user/app/bleeding-edge-update.nix.
  bleeding-edge-packages = final: prev: {
    bleeding-edge = import inputs.nixpkgs-bleeding-edge {
      system = prev.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };

  # NUR (Nix User Repository) for community packages like firefox-addons
  nur = inputs.nur.overlays.default;

  # Claude Desktop (unofficial Linux build)
  claude-desktop = inputs.claude-desktop.overlays.default;
}
