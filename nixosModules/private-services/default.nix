{ ... }:
{
  imports = [
    ./grafana.nix
    ./loki.nix
    ./postgres.nix
    ./postgres-exporter.nix
    ./blackbox-exporter
    ./prometheus
    ./alertmanager.nix
    ./vaultwarden.nix
    ./photoprism.nix
    ./tailforward.nix
    ./nginx.nix
    ./caddy.nix
    ./tempo.nix
    ./website.nix
    ./anki-sync-server.nix
  ];
}
