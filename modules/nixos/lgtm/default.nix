{...}: {
  imports = [
    ./alloy
    ./grafana.nix
    ./mimir.nix
    # These will be implemented later:
    # ./loki.nix
    # ./tempo.nix
  ];
}
