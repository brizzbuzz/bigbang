{
  description = "And God said, 'Let there be light,' and there was light.";

  inputs = {
    nixpkgs = {
      url = github:nixos/nixpkgs/nixos-23.11;
    };
    home-manager = {
      url = github:nix-community/home-manager/release-23.11;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    lib = nixpkgs.lib;
  in {
    # TODO: Better place?
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
    nixosConfigurations = {
      gigame = lib.nixosSystem {
        inherit system;
        modules = [
          ./system/configuration.nix
        ];
      };
    };
    homeConfigurations = {
      ryan = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [./profile/ryan.nix];
      };
    };
  };
}
