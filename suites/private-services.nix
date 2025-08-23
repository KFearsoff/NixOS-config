{ lib, ... }:
{
  nixchad = {
    caddy.enable = true;
    prometheus.enable = true;
    grafana.enable = true;
    vaultwarden.enable = true;
    postgres.enable = true;
    postgres-exporter.enable = true;
    blackbox-exporter.enable = true;
    loki.enable = true;
    photoprism.enable = lib.mkDefault true;
    tailforward.enable = true;
    tempo.enable = true;
    website.enable = true;
    anki-sync-server.enable = true;
  };
  networking.nat.enable = true;
}
