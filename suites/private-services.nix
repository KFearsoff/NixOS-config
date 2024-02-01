{lib, ...}: {
  nixchad = {
    nginx.enable = true;
    prometheus.enable = true;
    grafana.enable = true;
    invidious.enable = true;
    libreddit.enable = true;
    nitter.enable = true;
    vaultwarden.enable = true;
    postgres.enable = true;
    postgres-exporter.enable = true;
    blackbox-exporter.enable = true;
    redis-exporter.enable = true;
    loki.enable = true;
    photoprism.enable = lib.mkDefault true;
    tailforward.enable = true;
    tempo.enable = true;
    website.enable = true;
  };
  networking.nat.enable = true;
}
