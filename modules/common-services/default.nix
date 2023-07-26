{
  imports = [
    ./node-exporter.nix
    ./smartctl-exporter.nix
    ./grafana-agent.nix
    ./coredns.nix
    ./cadvisor.nix
    ./syncthing.nix
    ./restic.nix
  ];
}
