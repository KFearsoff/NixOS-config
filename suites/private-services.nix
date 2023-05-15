{lib, ...}: {
  nixchad.nginx.enable = true;
  nixchad.prometheus.enable = true;
  nixchad.grafana.enable = true;
  nixchad.invidious.enable = true;
  nixchad.libreddit.enable = true;
  nixchad.nitter.enable = true;
  nixchad.vaultwarden.enable = true;
  nixchad.postgres.enable = true;
  nixchad.postgres-exporter.enable = true;
  nixchad.blackbox-exporter.enable = true;
  nixchad.loki.enable = true;
  nixchad.photoprism.enable = lib.mkDefault true;
  networking.nat.enable = true;
}
