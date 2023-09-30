{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.bat;
in {
  options.nixchad.bat = {
    enable = mkEnableOption "bat";
  };

  config = mkIf cfg.enable {
    hm = {
      programs.bat = {
        enable = true;
        config = {
          theme = "base16";
          style = "plain";
        };
      };
    };
  };
}
