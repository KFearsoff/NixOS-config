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
  };

  config = {
    time.timeZone = cfg.timezone;
  };
}
