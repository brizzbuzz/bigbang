{
  lib,
  config,
  ...
}: {
  options = {
    host.nix = {
      enableOptimalCaching =
        lib.mkEnableOption "optimal Nix caching configuration"
        // {
          default = true;
        };
    };
  };

  config = lib.mkIf config.host.nix.enableOptimalCaching {
    nix = {
      settings = {
        # Experimental features
        experimental-features = ["nix-command" "flakes"];

        # Cache configuration
        download-buffer-size = 268435456; # 256MB
        substituters = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
          "https://colmena.cachix.org"
          "https://hyprland.cachix.org"
          "https://cuda-maintainers.cachix.org"
          "https://nixos-rocm.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg="
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
          "cuda-maintainers.cachix.org-1:0dq3bujKpuEPiCgBvmJ7pYGD+8DWvGYA2VhHfZUZhYk="
          "nixos-rocm.cachix.org-1:uuM0K2U1XGQYcv4VdGpHyxqjgJl9DzLlqsj/Y3iQNXc="
        ];

        # Performance optimizations
        builders-use-substitutes = true;
        max-jobs = "auto";
        cores = 0;
        http-connections = 25;
        keep-failed = false;

        # Allow importing from derivation for better cache usage
        allow-import-from-derivation = true;
      };

      # Garbage collection
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };

      # Optimization
      optimise = {
        automatic = true;
        dates = ["weekly"];
      };
    };
  };
}
