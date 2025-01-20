{
  forAllSystems,
  pkgs,
}:
forAllSystems (system: {
  default = pkgs.${system}.mkShell {
    packages = with pkgs.${system}; [
      git-cliff # Changelog generator
      nixos-generators # ISO and other image format generation
      nurl # Nix Fetcher Generator
      tokei # Code statistics
    ];
  };
})
