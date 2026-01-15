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
}
