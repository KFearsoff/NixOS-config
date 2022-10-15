{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.photoprism;
  hostname = config.networking.hostName;
  photoprismPort = 2342;
  photoprismDomain = "photoprism.${hostname}.me";
in {
  options.nixchad.photoprism = {
    enable = mkEnableOption "Photoprism photo gallery service";
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers."photoprism" = {
      image = "photoprism/photoprism";
      ports = ["${builtins.toString photoprismPort}:2342"];
      volumes = [
        "/home/nixchad/Pictures:/photoprism/originals:ro"
        "/photoprism/storage"
      ];
      environment = {
        PHOTOPRISM_UPLOAD_NSFW = "true";
        PHOTOPRISM_ADMIN_PASSWORD = "insecure";
        PHOTOPRISM_READONLY = "true";
      };
    };

    services.nginx.virtualHosts."${photoprismDomain}" = {
      forceSSL = true;
      sslCertificate = "/var/lib/self-signed/${photoprismDomain}/cert.pem";
      sslCertificateKey = "/var/lib/self-signed/${photoprismDomain}/key.pem";

      locations."/" = {
        proxyPass = "http://localhost:${builtins.toString photoprismPort}";
        proxyWebsockets = true;
      };
    };
    networking.extraHosts = ''
      127.0.0.1 ${photoprismDomain}
    '';
  };
}
