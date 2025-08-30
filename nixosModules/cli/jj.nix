{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.nixchad.jj;
in
{
  options.nixchad.jj = {
    enable = mkEnableOption "Jujutsu VCS";
  };

  config = mkIf cfg.enable {
    hm = {
      programs.jujutsu = {
        enable = true;
        settings = {
          user = {
            name = "KFears";
            email = "kfearsoff@gmail.com";
          };
          signing = {
            behavior = "own";
            backend = "ssh";
            key = "~/.ssh/id_ed25519.pub";
          };
          ui.pager = "less -FRX";
        };
      };
    };
  };
}
