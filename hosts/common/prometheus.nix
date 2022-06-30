{pkgs, config, ...}: {
  services.prometheus.exporters = {
    node = {
      enable = true;
      enabledCollectors = ["systemd"];
      openFirewall = true;
      #firewallFilter = "-i br0 -p tcp -m tcp --dport 9100";
    };
  };
  services.prometheus = {
    enable = true;
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [{
          targets = ["blueberry:${toString config.services.prometheus.exporters.node.port}"];
        }];
        scrape_interval = "15s";
      }
    ];
  };
  services.grafana = {
    enable = true;
    provision = {
      enable = true;
      datasources = [{
        name = "blueberry";
        type = "prometheus";
        url = "http://blueberry:9090";
      }];
    };
  };
}
