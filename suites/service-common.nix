{
  imports = [../modules/service-common];

  config = {
    nixchad.node-exporter.enable = true;
    nixchad.promtail.enable = true;
    nixchad.coredns.enable = true;
  };
}
