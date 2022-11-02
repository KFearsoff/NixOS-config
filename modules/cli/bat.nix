{
  config,
  lib,
  pkgs,
  username,
  ...
}: with lib; let
  cfg = config.nixchad.bat;
in {
  options.nixchad.bat = {
    enable = mkEnableOption "bat";
  };

  config = mkIf cfg.enable {
    home-manager.users."${username}" = {
      programs.bat = {
        enable = true;
        config = {
          theme = "base16";
          style = "plain";
        };
      };
      home.sessionVariables = {
        MANPAGER = "sh -c 'col -bx | ${pkgs.bat}/bin/bat -l man -p'";
      };
    };
  };
}
