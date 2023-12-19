{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nixchad.postgres;
in {
  options.nixchad.postgres = {
    enable = mkEnableOption "Prometheus Postgres";
  };

  config = mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      enableJIT = true;
      package = pkgs.postgresql_14;
    };

    nixchad.impermanence.persisted.values = [
      {
        directories =
          lib.mkIf (config.nixchad.impermanence.presets.essential && config.nixchad.impermanence.presets.services)
          [
            {
              directory = "/var/lib/postgresql"; # backup the whole dir recursively
              user = "postgres";
              group = "postgres";
            }
          ];
      }
    ];
  };
}
