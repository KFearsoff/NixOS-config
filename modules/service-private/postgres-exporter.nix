{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.postgres-exporter;
in {
  options.nixchad.postgres-exporter = {
    enable = mkEnableOption "Prometheus Postgres exporter";
  };

  config = mkIf cfg.enable {
    services.prometheus.exporters.postgres = {
      enable = true;
      port = 33002;
      dataSourceName = "user=postgres-exporter database=postgres host=/run/postgresql sslmode=disable";
      extraFlags = ["--auto-discover-databases"];
    };

    services.postgresql.ensureUsers = [{name = "postgres-exporter";}];
  };
}
