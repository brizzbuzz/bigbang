{
  description = "And God said, 'Let there be light,' and there was light.";

  nixConfig = {
    extra-substituters = [
      "https://colmena.cachix.org"
    ];
    extra-trusted-public-keys = [
      "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-latest.url = "github:nixos/nixpkgs/master"; # NOTE: Use sparingly

    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    alejandra = {
      url = "github:kamadorueda/alejandra/3.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    nixpkgs-unstable,
    nixpkgs-latest,
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
    colmena = {
      meta = {
        nixpkgs = import nixpkgs {
          system = "x86_64-linux";
          overlays = [];
        };
      };
      cloudy = {
        deployment = {
          targetUser = "god";
        };
        imports = [./hosts/cloudy/configuration.nix];
      };
    };
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
