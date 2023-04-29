{
  imports = [
    ./node-exporter.nix
    ./smartctl-exporter.nix
    ./vector.nix
    ./coredns
    ./cadvisor.nix
    ./syncthing.nix
    ./restic.nix
  ];
}
