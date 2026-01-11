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
          templates.commit_trailers = ''
            format_signed_off_by_trailer(self)
          '';
          git = {
            colocate = true;
            private-commits = "description('wip:*') | description('private:*')";
          };
          signing = {
            behavior = "own";
            backend = "ssh";
            key = "~/.ssh/id_ed25519.pub";
          };
          ui.pager = "less -FRX";
          "--scope" = [
            {
              "--when".repositories = [ "~/Documents/Work" ];
              user = {
                name = "Egor Terentev";
                email = "egor@naviteq.io";
              };
            }
            {
              "--when".repositories = [ "~/Documents/Projects-codeberg" ];
              user.email = "kfears@riseup.net";
            }
            {
              "--when".repositories = [ "~/Documents/Projects-gerrit" ];
              user.email = "kfears@riseup.net";
              templates.commit_trailers = ''
                format_signed_off_by_trailer(self)
                ++ if(!trailers.contains_key("Change-Id"), format_gerrit_change_id_trailer(self))
              '';
            }
          ];
        };
      };
    };
  };
}
