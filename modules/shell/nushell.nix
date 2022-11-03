{
  config,
  lib,
  pkgs,
  username,
  ...
}: with lib; let
  cfg = config.nixchad.nushell;
in {
  options.nixchad.nushell = {
    enable = mkEnableOption "nushell";
  };

  config = mkIf cfg.enable {
    home-manager.users."${username}" = {
      programs.nushell = {
        enable = true;
        configFile.source = ./config.nu;
        envFile.source = ./env.nu;
      };
    };
  };
}
