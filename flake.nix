{
  description = "Stefan's journey of NixOS adoption";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    #nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    nixpkgs-stable.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-fast-track.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-nordvpn.url = "github:different-error/nixpkgs/nordvpn";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    dms = {
      url = "github:AvengeMedia/DankMaterialShell/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    danksearch = {
      url = "github:AvengeMedia/danksearch";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-desktop = {
      url = "github:aaddrick/claude-desktop-debian";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix-on-Droid for Android devices (all pinned to 24.05)
    nixpkgs-android.url = "github:NixOS/nixpkgs/nixos-24.05";
    home-manager-android = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs-android";
    };
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs-android";
      inputs.home-manager.follows = "home-manager-android";
    };

    # Agenix for secrets management
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "";
    };
  };

  outputs =
    {
      self,
      home-manager,
      nixpkgs,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      # Linux systems only (NixOS-focused repo, custom packages don't support Darwin)
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      # Overlays for nixpkgs
      overlays = import ./overlays { inherit inputs; };
    in
    {
      # Export packages (excluding unfree ones that break flake check)
      packages = forAllSystems (
        system:
        let
          allPkgs = import ./pkgs nixpkgs.legacyPackages.${system};
        in
        builtins.removeAttrs allPkgs [ "steam-fix" ]
      );
      inherit overlays;
      nixosConfigurations = {
        stefan-t14 = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [ ./hosts/t14/configuration.nix ];
        };
        ZVIJER = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [ ./hosts/zvijer/configuration.nix ];
        };
        z420 = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [ ./hosts/z420/configuration.nix ];
        };
        starlabs = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [ ./hosts/starlabs/configuration.nix ];
        };

        # Servers
        dell-micro-3050 = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [ ./hosts/dell-micro-3050/configuration.nix ];
        };

        # Minimal liveboot host configuration (commented out - incomplete)
        # Uncomment and fix fileSystems config to use
        # liveboot = nixpkgs.lib.nixosSystem {
        #   specialArgs = {inherit inputs outputs;};
        #   modules = [./hosts/liveboot/configuration.nix];
        # };
        # Bootable ISO image based on liveboot configuration (commented out - incomplete)
        # liveboot-iso = nixpkgs.lib.nixosSystem {
        #   specialArgs = {inherit inputs outputs;};
        #   modules = [./hosts/liveboot/iso.nix];
        # };
      };

      # Nix-on-Droid configurations for Android devices
      # Deploy with: nix-on-droid switch --flake .#<device>
      nixOnDroidConfigurations = {
        # Samsung Galaxy Fold 6
        fold6 = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
          pkgs = import inputs.nixpkgs-android { system = "aarch64-linux"; };
          modules = [ ./hosts/android/fold6/nix-on-droid.nix ];
        };

        # Default configuration (alias to fold6)
        default = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
          pkgs = import inputs.nixpkgs-android { system = "aarch64-linux"; };
          modules = [ ./hosts/android/fold6/nix-on-droid.nix ];
        };
      };

      # Home-manager is now integrated into NixOS configurations
      # Deploy with: sudo nixos-rebuild switch --flake .#<hostname>
    };
}
