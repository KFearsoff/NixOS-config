{
  config,
  lib,
  username,
  ...
}:
with lib; let
  cfg = config.nixchad.location;
in {
  options.nixchad.location = {
    enable = mkEnableOption "location-based services";

    timezone = mkOption {
      type = types.str;
      default = "Europe/Moscow";
    };

    latitude = mkOption {
      type = types.float;
      default = 55.7;
    };

    longitude = mkOption {
      type = types.float;
      default = 37.6;
    };
  };

  config = mkIf cfg.enable {
    time.timeZone = cfg.timezone;

    home-manager.users."${username}" = {
      services.gammastep = mkIf config.nixchad.graphical.enable {
        enable = true;
        latitude = cfg.latitude;
        longitude = cfg.longitude;
      };
    };
  };
}
