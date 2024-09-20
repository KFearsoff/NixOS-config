{ lib, ... }:
{
  nixchad = {
    node-exporter.enable = true;
    cadvisor.enable = true;
    smartctl-exporter.enable = lib.mkDefault true;
    grafana-agent.enable = true;
    restic.enable = true;
  };
}
