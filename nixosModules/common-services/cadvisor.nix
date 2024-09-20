{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.nixchad.cadvisor;
in
{
  options.nixchad.cadvisor = {
    enable = mkEnableOption "cAdvisor";
  };

  config = mkIf cfg.enable {
    services.cadvisor = {
      enable = true;
      port = 9092;
    };

    nixchad.grafana-agent.metrics_scrape_configs = [
      {
        job_name = "cadvisor";
        static_configs = [
          {
            targets = [
              "localhost:9092"
            ];
          }
        ];
      }
    ];
  };
}
