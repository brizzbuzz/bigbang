{inputs}: {
  macme = inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    modules = [
      ../hosts/macme/configuration.nix
      inputs.nix-homebrew.darwinModules.nix-homebrew
      {
        nix-homebrew = {
          enable = true;
          user = "ryan"; # TODO: Inherit

          taps = {
            "homebrew/homebrew-core" = inputs.homebrew-core;
            "homebrew/homebrew-cask" = inputs.homebrew-cask;
            "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
          };

          mutableTaps = false;
        };
      }
    ];
    specialArgs = {
      inherit inputs;
      pkgs = import inputs.nixpkgs {
        system = "aarch64-darwin";
        config.allowUnfree = true;
        overlays = import ../modules/overlays;
      };
      pkgs-unstable = import inputs.nixpkgs-unstable {
        system = "aarch64-darwin";
        config.allowUnfree = true;
        overlays = import ../modules/overlays;
      };
    };
  };
}
