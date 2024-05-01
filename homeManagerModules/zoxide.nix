{
  config,
  lib,
  ...
}: let
  cfg = config.nixchad.zoxide;
  inherit (lib) mkEnableOption mkIf;
in {
  options.nixchad.zoxide = {
    enable = mkEnableOption "zoxide" // {default = config.nixchad.full.enable;};
  };

  config = mkIf cfg.enable {
    programs.zoxide.enable = true;
  };
}
