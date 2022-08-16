{
  imports = [../modules/service-common];

  config = {
    nixchad.nginx.enable = true;
    nixchad.prometheus.enable = true;
    nixchad.grafana.enable = true;
  };
}
