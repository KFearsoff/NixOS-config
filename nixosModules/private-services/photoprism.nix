{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.nixchad.photoprism;
  photoprismPort = 2342;
in
{
  options.nixchad.photoprism = {
    enable = mkEnableOption "Photoprism photo gallery service";
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers."photoprism" = {
      image = "photoprism/photoprism";
      ports = [ "${builtins.toString photoprismPort}:2342" ];
      volumes = [
        "/home/nixchad/Pictures/Photos:/photoprism/originals:ro"
        "/home/nixchad/Pictures/Photoprism:/photoprism/storage"
      ];
      environment = {
        PHOTOPRISM_UPLOAD_NSFW = "true";
        PHOTOPRISM_ADMIN_PASSWORD = "insecure";
        PHOTOPRISM_READONLY = "true";
      };
    };

    nixchad.nginx.vhosts."photoprism" = {
      port = photoprismPort;
    };
  };
}
