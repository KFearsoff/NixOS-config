{
  imports = [../modules/service-common];

  config = {
    nixchad.node-exporter.enable = true;
    nixchad.systemd-exporter.enable = true;
  };
}
