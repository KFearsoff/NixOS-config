{
  imports = [
    ./node-exporter.nix
    ./systemd-exporter.nix
    ./promtail.nix
    ./coredns
  ];
}
