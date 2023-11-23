{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nixchad.git;
  utilsEnabled = config.nixchad.utils.enable;
in {
  options.nixchad.git = {
    enable = mkEnableOption "git";
  };

  config = mkIf cfg.enable {
    programs.git.enable = true;

    hm = {
      home.packages = optionals utilsEnabled [pkgs.git-filter-repo pkgs.git-absorb];

      programs.git = {
        enable = true;
        lfs.enable = true;
        userEmail = "kfearsoff@gmail.com";
        userName = "KFears";

        aliases = {
          a = "add";
          d = "diff";
          dc = "diff --cached";
          sa = "stash push";
          sr = "stash pop";
          sl = "stash list";
          sd = "stash drop";
          c = "commit";
          ca = "commit --amend";
          r = "rebase";
          re = "restore";
          rs = "restore --staged";
          rc = "rebase --continue";
          ra = "rebase --abort";
          lp = "log -p";
          cp = "cherry-pick";
          cpc = "cherry-pick --continue";
          cpa = "cherry-pick --abort";
        };

        extraConfig = {
          init.defaultBranch = "main";
          diff.algorithm = "histogram";
          branch.autoSetupRebase = "always";
          rebase.autoStash = true;
          push.autoSetupRemote = "true";
          push.default = "current";

          url = {
            "ssh://git@github.com/".insteadOf = "gh:";
            "ssh://git@gitlab.com/".insteadOf = "gl:";
          };

          sequence.editor = optionalString utilsEnabled "${pkgs.git-interactive-rebase-tool}/bin/interactive-rebase-tool";
          interactive-rebase-tool = {
            inputMoveLeft = "h";
            inputMoveDown = "j";
            inputMoveUp = "k";
            inputMoveRight = "l";
            inputMoveHome = "g";
            inputMoveEnd = "G";
            inputMoveSelectionDown = "J";
            inputMoveSelectionUp = "K";
          };

          # commit signing
          gpg.format = "ssh";
          user.signingkey = "~/.ssh/id_ed25519.pub";
          commit.gpgsign = true;
        };

        includes = [
          {
            condition = "gitdir:/Documents/Work/**";
            contents = {
              user = {
                email = "egor@naviteq.io";
                name = "Egor Terentev";
              };
            };
          }
        ];

        difftastic = optionalAttrs utilsEnabled {
          enable = true;
          display = "inline";
        };
      };
    };
  };
}
