{...}: {
  imports = [
    ./alloy
    ./grafana.nix
    ./mimir.nix
    ./loki.nix
    # These will be implemented later:
    # ./tempo.nix
  ];
}
