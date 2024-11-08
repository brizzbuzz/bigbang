{
  forAllSystems,
  pkgs,
}:
forAllSystems (system: {
  default = pkgs.${system}.mkShell {
    packages = with pkgs.${system}; [
      git-cliff # Changelog generator
      # jujutsu # Git-compatible enriched VCS
      nurl # Nix Fetcher Generator
      tokei # Code statistics
    ];
  };
})
