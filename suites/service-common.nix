{
  imports = [../modules/service-common];

  config = {
    nixchad.nginx.enable = true;
    nixchad.prometheus.enable = true;
    nixchad.grafana.enable = true;
    nixchad.invidious.enable = true;
    nixchad.libreddit.enable = true;
    nixchad.nitter.enable = true;
    nixchad.vaultwarden.enable = true;
  };
}
