{
  description = "And God said, 'Let there be light,' and there was light.";

  inputs = {
    # NixOS Stuff
    nixpkgs.url = "github:nixos/nixpkgs/release-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-latest.url = "github:nixos/nixpkgs/master"; # NOTE: Use sparingly

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Formatter
    alejandra = {
      url = "github:kamadorueda/alejandra/3.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    # NixOS
    nixpkgs,
    nixpkgs-unstable,
    nixpkgs-latest,
    # Home Manager
    home-manager,
    ...
  } @ inputs: let
    system = builtins.currentSystem;
    lib = nixpkgs.lib;
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
    pkgs-latest = import nixpkgs-latest {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    nixosConfigurations = {
      frame = lib.nixosSystem {
        inherit system;
        modules = [
          ./system/frame/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.ryan = import ./profile/ryan.nix;
            home-manager.extraSpecialArgs = {
              inherit pkgs pkgs-unstable pkgs-latest;
            };
          }
        ];
        specialArgs = {
          inherit inputs;
        };
      };
      gigame = lib.nixosSystem {
        inherit system;
        modules = [
          ./system/gigame/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.ryan = import ./profile/ryan.nix;
            home-manager.extraSpecialArgs = {
              inherit inputs pkgs pkgs-unstable pkgs-latest;
            };
          }
        ];
        specialArgs = {
          inherit inputs;
        };
      };
    };
  };
}
