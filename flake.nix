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
  };

   outputs = {
    self,
    home-manager,
    nixpkgs,
    ...
  } @ inputs: let
    inherit (self) outputs;
    systems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    forAllSystems = nixpkgs.lib.genAttrs systems;

    # Apply overlays to nixpkgs
    overlays = import ./overlays {inherit inputs;};
    pkgs = nixpkgs.legacyPackages."x86_64-linux".extend (self: super: {
      overlays = [
        overlays.additions
        overlays.modifications
        overlays.stable-packages
        overlays.unstable-packages
      ];
    });
  in {
    packages =
      forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    inherit overlays;
    nixosConfigurations = {
      stefan-t14 = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [./hosts/t14/configuration.nix];
      };
      ZVIJER = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [./hosts/zvijer/configuration.nix];
      };
      z420 = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [./hosts/z420/configuration.nix];
      };
      starlabs = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [./hosts/starlabs/configuration.nix];
      };
      # Minimal liveboot host configuration
      liveboot = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [./hosts/liveboot/configuration.nix];
      };
      # Bootable ISO image based on liveboot configuration
      liveboot-iso = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [./hosts/liveboot/iso.nix];
      };
    };
    homeConfigurations = {
      # Legacy config (defaults to ZVIJER for backward compatibility)
      "stefanmatic" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [./home/stefanmatic.nix];
      };

      # Host-specific configs for stefanmatic
      "stefanmatic@ZVIJER" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          ./home/stefanmatic.nix
          {
            imports = [ ./user/wm/niri/ZVIJER.nix ];
          }
        ];
      };
      "stefanmatic@t14" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          ./home/stefanmatic.nix
          {
            imports = [ ./user/wm/niri/laptop.nix ];
          }
        ];
      };
      "stefanmatic@starlabs" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          ./home/stefanmatic.nix
          {
            imports = [ ./user/wm/niri/laptop.nix ];
          }
        ];
      };

      "fallen" = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [./home/fallen.nix];
      };
    };
  };
}

