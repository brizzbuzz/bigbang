{...}: {
  imports = [
    ./grafana.nix
    ./prometheus.nix
    # These will be implemented later:
    # ./loki.nix
    # ./tempo.nix
    # ./mimir.nix
  ];
}
