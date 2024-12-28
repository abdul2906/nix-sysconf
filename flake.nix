{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    impermanence.url = "github:nix-community/impermanence";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { 
    nixpkgs,
    impermanence,
    home-manager,
    plasma-manager,
    aagl,
    ...
  } @ inputs: let
    lib = nixpkgs.lib.extend (final: prev: 
      import ./lib { lib = final; }
    );
  in {
    nixosConfigurations = lib.mkHosts {
      modules = [
        home-manager.nixosModules.home-manager {
          home-manager.sharedModules = [ 
            plasma-manager.homeManagerModules.plasma-manager
          ];
        }
        impermanence.nixosModules.impermanence
      ];
      nixpkgs = nixpkgs;
      inputs = inputs;
    };
  };
}

