{...}: {
  imports = [
    ./grafana
    ./invidious.nix
    ./libreddit.nix
    ./loki.nix
    ./nitter.nix
    ./postgres.nix
    ./postgres-exporter.nix
    ./blackbox-exporter.nix
    ./redis-exporter.nix
    ./prometheus.nix
    ./alertmanager
    ./vaultwarden.nix
    ./photoprism.nix
    ./tailforward.nix
    ./nginx.nix
    ./tempo.nix
    ./coredns.nix
  ];
}
