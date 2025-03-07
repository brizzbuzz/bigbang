{
  forAllSystems,
  pkgs-master,
  ...
}:
forAllSystems (system: {
  default = pkgs-master.${system}.mkShell {
    packages = with pkgs-master.${system}; [
      claude-code # Claude Code
      git-cliff # Changelog generator
      nurl # Nix Fetcher Generator
      tokei # Code statistics
    ];
  };
})
