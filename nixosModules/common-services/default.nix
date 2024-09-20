{
  imports = [
    ./node-exporter.nix
    ./cadvisor.nix
    ./smartctl-exporter.nix
    ./grafana-agent.nix
    ./syncthing.nix
    ./restic.nix
  ];
}
