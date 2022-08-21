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
      openFirewall = true;
      port = 33002;
    };
  };
}
