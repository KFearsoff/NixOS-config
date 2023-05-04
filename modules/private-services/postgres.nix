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
  };
}
