{lib, ...}: {
  nixchad.node-exporter.enable = true;
  nixchad.smartctl-exporter.enable = lib.mkDefault true;
  nixchad.vector.enable = true;
  nixchad.coredns.enable = true;
  nixchad.cadvisor.enable = true;
  nixchad.restic.enable = true;
}
