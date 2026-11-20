{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mango = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, stylix, zen-browser, mango }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        mango.nixosModules.mango
        ({ config, ... }: {
          programs.mango = {
            enable = true;
            # Use the patched build
            package = config.home-manager.users.kotokrad.wayland.windowManager.mango.package;
          };
        })
        {
          home-manager.useUserPackages = true;
          home-manager.users.kotokrad = import ./laptop.nix;
          home-manager.extraSpecialArgs = {
            inherit inputs;
          };
        }
        stylix.nixosModules.stylix
        ./stylix.nix
      ];
    };

    homeConfigurations.macbook = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.aarch64-linux;
      extraSpecialArgs = { inherit inputs; };
      modules = [
        stylix.homeModules.stylix
        ./macbook.nix
      ];
    };
  };
}
