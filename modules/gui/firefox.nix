{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.nixchad.firefox;
in {
  options.nixchad.firefox = {
    enable = mkEnableOption "firefox";
  };

  config = mkIf cfg.enable {
    hm = {
      programs.firefox = {
        enable = true;
        package = inputs.firefox.packages.${pkgs.system}.firefox-nightly-bin;
      };
    };
  };
}
