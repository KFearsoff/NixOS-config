{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.nixchad.containers;
in
{
  options.nixchad.containers = {
    enable = mkEnableOption "containers";
  };

  config = mkIf cfg.enable {
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
    };

    nixchad.impermanence.persisted.values = [
      {
        directories = lib.mkIf config.nixchad.impermanence.presets.system [ "/var/lib/containers" ];
      }
    ];
  };
}
