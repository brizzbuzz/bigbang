{
  description = "And God said, 'Let there be light,' and there was light.";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs;
    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
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
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
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
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.ryan = import ./profile/ryan.nix;
          }
        ];
      };
    };
    homeConfigurations = {
      # TODO: Convert to module approach like above
      cloudy = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [./profile/cloudy.nix];
      };
    };
  };
}
