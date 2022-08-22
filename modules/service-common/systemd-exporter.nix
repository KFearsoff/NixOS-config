{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.systemd-exporter;
in {
  options.nixchad.systemd-exporter = {
    enable = mkEnableOption "Prometheus systemd exporter";
  };

  config = mkIf cfg.enable {
    services.prometheus.exporters.systemd = {
      enable = true;
      openFirewall = true;
      port = 33004;
      extraFlags = ["--systemd.collector.enable-restart-count" "--systemd.collector.enable-file-descriptor-size" "--systemd.collector.enable-ip-accounting"];
    };
  };
}
