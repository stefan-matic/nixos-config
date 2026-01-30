{
  description = "Stefan's journey of NixOS adoption";

  inputs = {
    #nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    nixpkgs-stable.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager.url = "github:nix-community/home-manager?ref=release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
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
      # Home-manager is now integrated into NixOS configurations
      # Deploy with: sudo nixos-rebuild switch --flake .#<hostname>
    };
}
