{...}: {
  imports = [
    ./alloy
    ./grafana.nix
    ./mimir.nix
    ./loki.nix
    ./tempo.nix
  ];
}
