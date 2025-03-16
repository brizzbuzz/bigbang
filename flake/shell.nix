{
  forAllSystems,
  pkgs-master,
  ...
}:
forAllSystems (system: {
  default = pkgs-master.${system}.mkShell {
    packages = with pkgs-master.${system}; [
      alejandra # Nix Formatter
      claude-code # Claude Code
      git-cliff # Changelog generator
      grafana-alloy # Grafana Alloy
      nil # Nix LSP
      nurl # Nix Fetcher Generator
      tokei # Code statistics
    ];
  };
})
