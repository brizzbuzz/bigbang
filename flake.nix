{
  description = "And God said, 'Let there be light,' and there was light.";

  inputs = {
    # NixOS Stuff
    nixpkgs.url = "github:nixos/nixpkgs/release-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Flake Utils
    flake-utils.url = "github:numtide/flake-utils";

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

    # MacOS Stuff
    # TODO: Cleaner way to declare this? Don't like bloating this file
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs = {
  self,
    # Formatter
    alejandra,
    # NixOS
    nixpkgs,
    nixpkgs-unstable,
    # Flake Utils
    flake-utils,
    # MacOS
    darwin,
    homebrew,
    homebrew-core,
    homebrew-cask,
    homebrew-bundle,
    # Home Manager
    home-manager,
    ...
  }: let
    pkgs = import nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };
    pkgs-darwin = import nixpkgs {
      system = "aarch64-darwin";
      config.allowUnfree = true;
    };
    pkgs-unstable = import nixpkgs-unstable {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };
    pkgs-unstable-darwin = import nixpkgs-unstable {
      system = "aarch64-darwin";
      config.allowUnfree = true;
    };

    lib = nixpkgs.lib;
  in {
    devShell = flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      {
        packages = rec {
          hello = pkgs.hello;
          default = hello;
        };
        apps = rec {
          hello = flake-utils.lib.mkApp { drv = self.packages.${system}.hello; };
          default = hello;
        };
      }
    );
    nixosConfigurations = {
      cloudy = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./system/cloudy/configuration.nix
          {
            environment.systemPackages = [alejandra.defaultPackage."x86_64-linux"];
          }
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.ryan = import ./cloudy/ryan.nix;
          }
        ];
      };
      gigame = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./system/gigame/configuration.nix
          {
            environment.systemPackages = [alejandra.defaultPackage."x86_64-linux"];
          }
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.ryan = import ./profile/ryan.nix;
            home-manager.extraSpecialArgs = {
              inherit pkgs;
              inherit pkgs-unstable;
            };
          }
        ];
        specialArgs = {
          inherit pkgs;
          inherit pkgs-unstable;
        };
      };
    };
    darwinConfigurations = {
      megame = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./system/megame/configuration.nix
          {
            # NOTE: `${system}` doesn't work here and I'm really not clear why
            environment.systemPackages = [alejandra.defaultPackage."aarch64-darwin"];
          }
          # TODO: Figure out how to move these to a separate file
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.ryan = import ./profile/ryan-mbp.nix;
            home-manager.extraSpecialArgs = {
              pkgs = pkgs-darwin;
              pkgs-unstable = pkgs-unstable-darwin;
            };
          }
          homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = false;
              user = "ryan";

              # Declarative tap management
              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
                "homebrew/homebrew-bundle" = homebrew-bundle;
              };

              # Disable imperative tap management
              mutableTaps = false;
            };
          }
        ];
      };
    };
  };
}
