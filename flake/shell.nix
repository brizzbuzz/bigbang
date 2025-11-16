{
  forAllSystems,
  pkgs,
  inputs,
  ...
}:
forAllSystems (system: {
  default = pkgs.${system}.mkShell {
    packages = with pkgs.${system}; [
      alejandra # Nix Formatter
      colmena # NixOS deployment tool
      deadnix # Dead code scanner for Nix files
      git-cliff # Changelog generator
      nurl # Nix Fetcher Generator
      tokei # Code statistics
      inputs.opnix.packages.${system}.default # OpNix CLI
    ];

    # Shell hook to ensure proper cache configuration
    shellHook = ''
      echo "🚀 BigBang Development Environment"
      echo "📦 Cache configuration active - using binary caches for faster builds"

      # Verify cache configuration is working
      if nix show-config | grep -q "substituters.*cachix"; then
        echo "✅ Cachix substituters configured"
      else
        echo "⚠️  Cache configuration may need attention"
      fi
    '';

    # Set environment variables for better build performance
    NIX_CONFIG = ''
      experimental-features = nix-command flakes
      max-jobs = auto
      cores = 0
      substituters = https://cache.nixos.org https://nix-community.cachix.org https://colmena.cachix.org https://hyprland.cachix.org
      trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg= hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=
    '';
  };
})
