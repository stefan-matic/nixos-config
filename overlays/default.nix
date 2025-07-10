{ inputs, ... }: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
    modifications = final: prev:
    {
      # Override pyscard to use version 2.2.1 instead of 2.2.2
      python3Packages = prev.python3Packages.override {
        overrides = python-final: python-prev: {
          pyscard = python-prev.pyscard.overrideAttrs (oldAttrs: rec {
            version = "2.2.1";
            src = prev.fetchPypi {
              pname = "pyscard";
              version = version;
              sha256 = "sha256-kg5oilEIIkyxm5FcP9fqfPPRqjeVh//Qh5c+hME/jZQ=";
            };
          });
        };
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

