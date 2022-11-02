{
  imports = [../modules/common-services];

  config = {
    nixchad.node-exporter.enable = true;
    nixchad.smartctl-exporter.enable = true;
    nixchad.promtail.enable = true;
    nixchad.coredns.enable = true;
    nixchad.blackbox-exporter.enable = true;
    nixchad.cadvisor.enable = true;
  };
}
