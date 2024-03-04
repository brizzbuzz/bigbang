{
  description = "And God said, 'Let there be light,' and there was light.";

  inputs = {
    # NixOS Stuff
    nixpkgs.url = "github:nixos/nixpkgs/release-23.11";

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
    # Formatter
    alejandra,
    # NixOS
    nixpkgs,
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
    system = "x86_64-linux"; # TODO: How to switch this if necessary?
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    lib = nixpkgs.lib;
  in {
    # TODO: Better place?
    #formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
    nixosConfigurations = {
      cloudy = lib.nixosSystem {
        inherit system;
        modules = [
          ./system/cloudy/configuration.nix
        ];
      };
      gigame = lib.nixosSystem {
        inherit system;
        modules = [
          ./system/gigame/configuration.nix
          {
            environment.systemPackages = [alejandra.defaultPackage.${system}];
          }
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.ryan = import ./profile/ryan.nix;
          }
        ];
      };
    };
    darwinConfigurations = {
      megame = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./system/megame/configuration.nix
          # TODO: Figure out how to move this to a separate file
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.ryan = import ./profile/ryan-mbp.nix;
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
    # TODO: Would be nice to move these to nixConfiguration to streamline build process, like darwin setup
    homeConfigurations = {
      # TODO: Convert to module approach like above
      cloudy = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [./profile/cloudy.nix];
      };
    };
  };
}
