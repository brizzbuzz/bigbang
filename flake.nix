{
  description = "And God said, 'Let there be light,' and there was light.";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://colmena.cachix.org"
      "https://hyprland.cachix.org"
      "https://cuda-maintainers.cachix.org"
      "https://nixos-rocm.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPiCgBvmJ7pYGD+8DWvGYA2VhHfZUZhYk="
      "nixos-rocm.cachix.org-1:uuM0K2U1XGQYcv4VdGpHyxqjgJl9DzLlqsj/Y3iQNXc="
    ];
    allow-dirty = true;
    # Ensure binary caches are prioritized
    max-jobs = "auto";
    cores = 0;
    # Allow importing from derivation for better cache usage
    allow-import-from-derivation = true;
    # Prevent unnecessary rebuilds
    builders-use-substitutes = true;
    # Keep failed builds for debugging but don't waste time
    keep-failed = false;
    # Use all available download bandwidth
    http-connections = 25;
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-compat.url = "github:edolstra/flake-compat";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
    systems.url = "github:nix-systems/default";
    systems-linux.url = "github:nix-systems/default-linux";

    authentik-nix = {
      url = "github:nix-community/authentik-nix";
      inputs.flake-compat.follows = "flake-compat";
      inputs.flake-parts.follows = "flake-parts";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems-linux";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };

    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };

    hyperbaric = {
      url = "git+ssh://git@github.com/brizzbuzz/hyperbaric";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.opnix.follows = "opnix";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
    };

    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    opnix = {
      url = "github:brizzbuzz/opnix";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spacebarchat = {
      url = "github:spacebarchat/server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {nixpkgs, ...} @ inputs: let
    supportedSystems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    nixpkgsConfig = {
      config = {
        allowUnfree = true;
      };
    };

    pkgs = forAllSystems (system:
      import nixpkgs {
        inherit system;
        inherit (nixpkgsConfig) config;
      });
  in {
    darwinConfigurations = import ./flake/darwin.nix {inherit inputs;};
    colmena = import ./flake/nixos.nix {inherit inputs;};
    devShells = import ./flake/shell.nix {inherit forAllSystems pkgs inputs;};

    # NixOS configurations for nixos-install
    nixosConfigurations = {
      frame = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          inputs.disko.nixosModules.disko
          ./hosts/frame/configuration.nix
        ];
      };

      callisto = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          inputs.disko.nixosModules.disko
          ./hosts/callisto/configuration.nix
        ];
      };

      ganymede = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/ganymede/configuration.nix
        ];
      };
    };
  };
}
