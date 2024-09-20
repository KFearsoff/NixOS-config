{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.nixchad.mpd;
in
{
  options.nixchad.mpd = {
    enable = mkEnableOption "mpd";
  };

  config = mkIf cfg.enable {
    hm = {
      services.mpd.enable = true;
    };
  };
}
