{inputs}: let
  mkDarwinSystem = {
    system ? "aarch64-darwin",
    username ? "ryan",
    extraModules ? [],
  }:
    inputs.nix-darwin.lib.darwinSystem {
      inherit system;
      modules =
        [
          ../hosts/macme/configuration.nix
          inputs.nix-homebrew.darwinModules.nix-homebrew
          {
            system.primaryUser = username;
            nix-homebrew = {
              enable = true;
              user = username;

              taps = {
                "homebrew/homebrew-core" = inputs.homebrew-core;
                "homebrew/homebrew-cask" = inputs.homebrew-cask;
                "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
              };

              mutableTaps = false;
            };
          }
        ]
        ++ extraModules;
      specialArgs = {
        inherit inputs;
        pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = import ../modules/overlays;
        };
      };
    };
in {
  Odyssey-MBP = mkDarwinSystem {};
  Mac-Mini = mkDarwinSystem {};
}
