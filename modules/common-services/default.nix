{
  imports = [
    ./node-exporter.nix
    ./smartctl-exporter.nix
    ./grafana-agent.nix
    ./coredns
    ./cadvisor.nix
    ./syncthing.nix
    ./restic.nix
  ];
}
