{
  config,
  lib,
  pkgs,
  username,
  ...
}: with lib; let
  cfg = config.nixchad.git;
  utilsEnabled = config.nixchad.utils.enable;
in {
  options.nixchad.git = {
    enable = mkEnableOption "git";
  };

  config = mkIf cfg.enable {
    programs.git.enable = true;

    hm = {
      home.packages = optional utilsEnabled pkgs.git-filter-repo;
      home.shellAliases = {
        gd = "git diff ";
        gdc = "git diff --cached";
        gl = "git log --graph --color --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        gst = "git status ";
        gsa = "git stash push ";
        gsr = "git stash pop ";
        gsl = "git stash list ";
        gsd = "git stash drop ";
        gc = "git commit ";
        gca = "git commit --amend ";
        gr = "git rebase ";
        gpa = "git pull --all";
        ga = "git add";
        gre = "git restore ";
        grs = "git restore --staged";
        grc = "git rebase --continue";
        gra = "git rebase --abort";
        glp = "git log -p";
        gcp = "git cherry-pick";
        gcpc = "git cherry-pick --continue";
        gcpa = "git cherry-pick --abort";
      };

      programs.git = {
        enable = true;
        userEmail = "kfearsoff@gmail.com";
        userName = "KFears";
        extraConfig = {
          init.defaultBranch = "main";
          merge.conflictStyle = "diff3";
          push.autoSetupRemote = "true";
          diff = {
            colorMoved = "default";
            sopsdiffer.textconv = "${pkgs.sops}/bin/sops -d";
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
        };
        delta = optionalAttrs utilsEnabled {
          enable = true;
          options = {
            navigate = true;
            line-numbers = true;
            syntax-theme = "base16";
            side-by-side = true;
          };
        };
      };
    };
  };
}
