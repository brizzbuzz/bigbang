{
  description = "And God said, 'Let there be light,' and there was light.";

  nixConfig = {
    extra-substituters = [
      "https://colmena.cachix.org"
      "https://devenv.cachix.org"
    ];
    extra-trusted-public-keys = [
      "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";

    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    alejandra = {
      url = "github:kamadorueda/alejandra/3.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    devenv,
    home-manager,
    nixpkgs,
    nixpkgs-unstable,
    systems,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    forEachSystem = nixpkgs.lib.genAttrs (import systems);
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
    hello = pkgs.callPackage ./modules/derivations/hello.nix {};
    glance = pkgs.callPackage ./modules/derivations/glance.nix {inherit pkgs-unstable;};
  in {
    colmena = {
      meta = {
        specialArgs = {
          inherit
            inputs
            pkgs
            pkgs-unstable
            hello
            glance
            ;
        };
        # NOTE: Not sure why but you also need to specify nixpkgs here
        # TODO: Figure out why
        nixpkgs = import nixpkgs {
          inherit system;
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
          targetUser = "ryan";
        };
      };
    };

    devShells = forEachSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      default = devenv.lib.mkShell {
        inherit inputs pkgs;
        modules = [
          {
            packages = with pkgs-unstable; [
              git-cliff # Changelog generator
              lua-language-server # Lua Language Server
              nil # Nix Language Server
              nurl # Nix Fetcher Generator
              stylua # Lua formatter
              tokei # Code statistics
            ];
          }
        ];
      };
    });
  };
}
