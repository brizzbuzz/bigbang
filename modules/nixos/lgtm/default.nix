{...}: {
  imports = [
    ./alloy.nix
    ./grafana.nix
    ./mimir.nix
    ./loki.nix
    ./tempo.nix
  ];
}
