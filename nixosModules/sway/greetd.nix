{
  config,
  lib,
  username,
  ...
}:
with lib; let
  cfg = config.nixchad.greetd;
in {
  options.nixchad.greetd = {
    enable = mkEnableOption "greetd";
  };

  config = mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          command = "$SHELL -l";
          user = "${username}";
        };
        default_session = initial_session;
      };
    };
  };
}
