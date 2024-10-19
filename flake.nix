{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    #hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";

    hyprland = {
      type = "git";
      url = "https://code.hyprland.org/hyprwm/Hyprland.git";
      submodules = true;
      #rev = "0f594732b063a90d44df8c5d402d658f27471dfe"; #v0.43.0
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland-plugins = {
      type = "git";
      url = "https://code.hyprland.org/hyprwm/hyprland-plugins.git";
      #rev = "b73d7b901d8cb1172dd25c7b7159f0242c625a77"; #v0.43.0
      inputs.hyprland.follows = "hyprland";
    };
    hyprlock = {
      type = "git";
      url = "https://code.hyprland.org/hyprwm/hyprlock.git";
      #rev = "73b0fc26c0e2f6f82f9d9f5b02e660a958902763";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprpaper = {
      type = "git";
      url = "https://code.hyprland.org/hyprwm/hyprpaper.git";
      #rev = "73b0fc26c0e2f6f82f9d9f5b02e660a958902763";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprswitch = {
      type = "git";
      url = "https://github.com/H3rmt/hyprswitch.git";
      #rev = "73b0fc26c0e2f6f82f9d9f5b02e660a958902763";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix.url = "github:danth/stylix";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
  let
    systemSettings = {
      system = "x86_64-linux";
      hostname = "RWTF";
      profile = "starlabs";
      timezone = "Europe/Sarajevo";
      locale = "en_US.UTF-8";
    };

    # Rec is recursive when you need more complex sets and nests
    #userSettings = rec {
    userSettings = {
      username = "fallen";
      name = "Fallen";
      email = "lordmata94@gmail.com";
      theme = "dracula";
      term = "alacritty"; # Default terminal command;
      font = "Intel One Mono"; # Selected font
      fontPkg = pkgs.intel-one-mono; # Font package
      editor = "nano"; # Default editor;
    };

    #pkgs = nixpkgs.legacyPackages.${systemSettings.system};

    #Ovo si morao jer unfree ne radi bez toga za home manager
    pkgs = import nixpkgs { 
      system = systemSettings.system; 
      config = {
        allowUnfree = true;
        allowUnfreePredicate = (_: true);
      };
      overlays = [ self.overlays.default ];
    };
  
  in {

    overlays.default = final: prev: {
      stefan = final.callPackage ./custom-pkgs/figurine.nix { };
    };

    nixosConfigurations.${systemSettings.hostname} = nixpkgs.lib.nixosSystem {
      system = systemSettings.system;
      modules = [
        (./. + "/profiles" + ("/" + systemSettings.profile) + "/configuration.nix")
        #({ pkgs, ...}: {
        #  environment.systemPackages = [ pkgs.figurine ];
        #})
      ];
      specialArgs = { 
        inherit pkgs;
        #inherit pkgs-unstable;
        inherit systemSettings; 
        inherit userSettings; 
        inherit inputs; 
      };
    };

    homeConfigurations.${userSettings.username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          (./. + "/profiles" + ("/" + systemSettings.profile) + "/home.nix")
        ];
        extraSpecialArgs = {
          inherit pkgs;
          #inherit pkgs-unstable;
          inherit userSettings; 
          inherit systemSettings; 
          inherit inputs; 
        };
    };
  };
}

