{inputs}: let
  mkDarwinSystem = {
    system ? "aarch64-darwin",
    username ? "ryan",
    users ? {},
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

            host.users = users;
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
  # 14" MacBook Pro
  pip = mkDarwinSystem {
    users = {
      ryan = {
        name = "ryan";
        profile = "personal";
        isPrimary = true;
        homeManagerEnabled = true;
      };
      Work = {
        name = "Work";
        profile = "work";
        isPrimary = false;
        homeManagerEnabled = true;
      };
    };
  };

  # 16" MacBook Pro
  ember = mkDarwinSystem {
    users = {
      ryan = {
        name = "ryan";
        profile = "personal";
        isPrimary = true;
        homeManagerEnabled = true;
      };
      Work = {
        name = "Work";
        profile = "work";
        isPrimary = false;
        homeManagerEnabled = true;
      };
    };
  };

  # Mac Mini
  dot = mkDarwinSystem {
    users = {
      ryan = {
        name = "ryan";
        profile = "personal";
        isPrimary = true;
        homeManagerEnabled = true;
      };
      Work = {
        name = "Work";
        profile = "work";
        isPrimary = false;
        homeManagerEnabled = true;
      };
    };
  };
}
