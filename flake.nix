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
    nixpkgs.url = "github:nixos/nixpkgs/release-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    alejandra = {
      url = "github:kamadorueda/alejandra/3.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    darwin,
    home-manager,
    nixpkgs,
    nixpkgs-unstable,
    nixvim,
    ...
  } @ inputs: let
    supportedSystems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    pkgs = forAllSystems (system: nixpkgs.legacyPackages.${system});
  in {
    darwinConfigurations.macme = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./hosts/macme/configuration.nix
      ];
      specialArgs = {
        inherit inputs;
        pkgs-unstable = import nixpkgs-unstable {
          system = "aarch64-darwin";
          config.allowUnfree = true;
        };
      };
    };
    colmena = {
      meta = {
        specialArgs = {
          inherit
            inputs
            ;
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          pkgs-unstable = import nixpkgs-unstable {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
        };
        nixpkgs = import nixpkgs {
          system = "x86_64-linux";
          overlays = [];
        };
      };
      frame = {
        imports = [./hosts/frame/configuration.nix];
        deployment = {
          allowLocalDeployment = true;
          targetUser = "ryan";
        };
      };
      gigame = {
        imports = [./hosts/gigame/configuration.nix];
        deployment = {
          allowLocalDeployment = true;
          targetUser = "ryan";
        };
      };
      cloudy = {
        imports = [./hosts/cloudy/configuration.nix];
        deployment = {
          allowLocalDeployment = true;
          buildOnTarget = true;
          targetUser = "ryan";
        };
      };
    };

    devShells = forAllSystems (system: {
      default = pkgs.${system}.mkShell {
        packages = with pkgs.${system}; [
          git-cliff # Changelog generator
          jujutsu # Git-compatible enriched VCS
          nurl # Nix Fetcher Generator
          tokei # Code statistics
        ];
      };
    });
  };
}
