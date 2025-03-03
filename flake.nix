{
  description = "Stefan's journey of NixOS adoption";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:danth/stylix";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = (_: true);
        };
        overlays = [ self.overlays.default ];
      };

    in
    {

      overlays.default = final: prev: {
        stefan = final.callPackage ./custom-pkgs/figurine.nix { };
      };

      nixosConfigurations = {
        RWTF = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/starlabs/configuration.nix
          ];
          specialArgs = {
            inherit pkgs;
            inherit inputs;
          };
        };

        ZVIJER = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/zvijer/configuration.nix
          ];
          specialArgs = {
            inherit pkgs;
            inherit inputs;
          };
        };

        nix-vm = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/nix-vm/configuration.nix
          ];
          specialArgs = {
            inherit pkgs;
            inherit inputs;
          };
        };
      };

      homeConfigurations = {
        stefanmatic = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home/stefanmatic.nix
          ];
          extraSpecialArgs = {
            inherit pkgs;
            inherit inputs;
          };
        };

        fallen = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home/fallen.nix
          ];
          extraSpecialArgs = {
            inherit pkgs;
            inherit inputs;
          };
        };
      };
    };
}

