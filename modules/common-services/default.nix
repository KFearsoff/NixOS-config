{
  imports = [
    ./node-exporter.nix
    ./smartctl-exporter.nix
    ./promtail.nix
    ./coredns
    ./cadvisor.nix
    ./syncthing.nix
    ./restic.nix
  ];
}
