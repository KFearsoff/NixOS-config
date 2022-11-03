{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.invidious;
  hostname = config.networking.hostName;
  invidiousPort = toString config.services.invidious.port;
  invidiousDomain = "invidious.${hostname}.box";
in {
  options.nixchad.invidious = {
    enable = mkEnableOption "Invidious Youtube proxying service";
  };

  config = mkIf cfg.enable {
    services.invidious.enable = true;
    services.invidious.port = 32000;
    services.invidious.domain = invidiousDomain;

    # FIXME: Invidious doesn't support subpaths and has no plans to:
    # https://github.com/iv-org/invidious/issues/2441
    # Tailscale doesn't support wildcards domains and has no plans to:
    # https://github.com/tailscale/tailscale/issues/1196
    # Tailscale will support subdomains later:
    # https://github.com/tailscale/tailscale/issues/1235#issuecomment-927002943
    # Wait for it to land, then update Invidious to be exposed through MagicDNS
    services.nginx.virtualHosts."${invidiousDomain}" = {
      forceSSL = true;
      sslCertificate = "/var/lib/self-signed/_.blackberry.box/cert.pem";
      sslCertificateKey = "/var/lib/self-signed/_.blackberry.box/key.pem";

      locations."/" = {
        proxyPass = "http://localhost:${invidiousPort}";
      };
    };
  };
}
