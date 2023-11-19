{lib, ...}: {
  nixchad = {
    node-exporter.enable = true;
    smartctl-exporter.enable = lib.mkDefault true;
    grafana-agent.enable = true;
    cadvisor.enable = true;
    restic.enable = true;
  };
}
