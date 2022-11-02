{
  imports = [
    ./node-exporter.nix
    ./smartctl-exporter.nix
    ./promtail.nix
    ./coredns
    ./blackbox-exporter.nix
    ./cadvisor.nix
    ./syncthing.nix
  ];
}
