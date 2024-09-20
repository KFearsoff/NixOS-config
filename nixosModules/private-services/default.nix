{ ... }:
{
  imports = [
    ./grafana.nix
    ./invidious.nix
    ./loki.nix
    ./postgres.nix
    ./postgres-exporter.nix
    ./blackbox-exporter.nix
    ./prometheus.nix
    ./alertmanager.nix
    ./vaultwarden.nix
    ./photoprism.nix
    ./tailforward.nix
    ./nginx.nix
    ./tempo.nix
    ./website.nix
  ];
}
