{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.cadvisor;
in {
  options.nixchad.cadvisor = {
    enable = mkEnableOption "cadvisor";
  };

  config = mkIf cfg.enable {
    services.cadvisor = {
      enable = true;
      port = 33006;
      listenAddress = "0.0.0.0";
    };

    nixchad.grafana-agent.metrics_scrape_configs = [
      {
        job_name = "cadvisor";
        static_configs = [
          {
            targets = [
              "localhost:33006"
            ];
          }
        ];
      }
    ];
  };
}
