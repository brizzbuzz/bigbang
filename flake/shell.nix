{
  forAllSystems,
  pkgs,
}:
forAllSystems (system: {
  default = pkgs.${system}.mkShell {
    packages = with pkgs.${system}; [
      git-cliff # Changelog generator
      nurl # Nix Fetcher Generator
      tokei # Code statistics
    ];
  };
})
