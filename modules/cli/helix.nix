{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.helix;
in {
  options.nixchad.helix = {
    enable = mkEnableOption "helix";
  };

  config = mkIf cfg.enable {
    hm.programs.helix = {
      enable = true;
      defaultEditor = true;
      settings = {
        theme = "dracula";
        editor = {
          line-number = "relative";
        };
      };
    };
  };
}
