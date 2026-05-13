{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {

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
