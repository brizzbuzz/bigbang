{
  description = "And God said, 'Let there be light,' and there was light.";

  inputs = {
    # NixOS Stuff
    nixpkgs.url = "github:nixos/nixpkgs/release-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # NOTE: Seriously only use this if you absolutely need to, will almost definitely build things from source
    nixpkgs-latest.url = "github:nixos/nixpkgs/master";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland-nix = {
      url = "github:hyprland-community/hyprland-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    alejandra = {
      url = "github:kamadorueda/alejandra/3.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    alejandra,
    nixpkgs,
    nixpkgs-unstable,
    nixpkgs-latest,
    home-manager,
    hyprland-nix,
    ...
  }: let
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
          {
            environment.systemPackages = [alejandra.defaultPackage.${system}];
          }
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.ryan = import ./profile/ryan.nix;
            home-manager.extraSpecialArgs = {
              inherit pkgs pkgs-unstable pkgs-latest hyprland-nix;
            };
          }
        ];
        specialArgs = {
          inherit pkgs pkgs-unstable pkgs-latest;
        };
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
            home-manager.extraSpecialArgs = {
              inherit pkgs pkgs-unstable pkgs-latest;
            };
          }
        ];
        specialArgs = {
          inherit pkgs pkgs-unstable pkgs-latest;
        };
      };
    };
  };
}
