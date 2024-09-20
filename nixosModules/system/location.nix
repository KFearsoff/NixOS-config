{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.nixchad.location;
in
{
  options.nixchad.location = {
    timezone = mkOption {
      type = types.str;
      default = "Asia/Tbilisi";
    };

    latitude = mkOption {
      type = types.float;
      default = 41.43;
    };

    longitude = mkOption {
      type = types.float;
      default = 44.47;
    };
  };

  config = {
    time.timeZone = cfg.timezone;

    hm = {
      services.gammastep = mkIf config.nixchad.gui.enable {
        enable = true;
        inherit (cfg) latitude;
        inherit (cfg) longitude;
      };
    };
  };
}
