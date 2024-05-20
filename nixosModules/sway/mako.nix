{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.mako;
in {
  options.nixchad.mako = {
    enable = mkEnableOption "mako";
  };

  config = mkIf cfg.enable {
    hm = {
      services.mako = {
        enable = true;

        defaultTimeout = 5000; # ms
        ignoreTimeout = true;
      };
    };
  };
}
