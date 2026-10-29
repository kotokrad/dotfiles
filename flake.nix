{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database= {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mango = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nur, stylix, zen-browser, mango, nix-index-database }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        nur.modules.nixos.default
        home-manager.nixosModules.home-manager
        mango.nixosModules.mango
        {
          programs.mango.enable = true;
        }
        {
          nixpkgs.overlays = [ nur.overlays.default ];
          home-manager.useUserPackages = true;
          home-manager.users.kotokrad = import ./home.nix;
          home-manager.extraSpecialArgs = {
            inherit inputs;
          };
        }
        stylix.nixosModules.stylix
        ./stylix.nix
        nix-index-database.nixosModules.default
      ];
    };
  };
}
