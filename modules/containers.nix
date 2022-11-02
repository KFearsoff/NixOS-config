{
  config,
  lib,
  ...
}: 
with lib; let
  cfg = config.nixchad.containers;
in {
  options.nixchad.containers = {
    enable = mkEnableOption "containers";
  };

  config = mkIf cfg.enable {
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
    };

    environment.persistence."/persist" = {
      directories = [
        "/var/lib/containers"
      ];
    };
  };
}
