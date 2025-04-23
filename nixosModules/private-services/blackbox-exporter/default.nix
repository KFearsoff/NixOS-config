# https://gitlab.com/K900/nix/-/blob/f164e274309d9a9b5d1e587f8d9adcc424a2feaf/machines/yui/grafana/blackbox_exporter.nix
{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.nixchad.blackbox-exporter;
in
{
  options.nixchad.blackbox-exporter = {
    enable = mkEnableOption "Prometheus blackbox exporter";
  };

  config = mkIf cfg.enable {
    environment.etc = {
      "alloy/blackbox-exporter.alloy".source = ./blackbox-exporter.alloy;
      "alloy/blackbox-exporter.yaml".source = ./blackbox-exporter.yaml;
    };
  };
}
