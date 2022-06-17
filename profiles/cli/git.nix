{
  username,
  pkgs,
  ...
}: {
  programs.git.enable = true;

  home-manager.users."${username}" = {
    home.packages = [
      pkgs.git-filter-repo
    ];
    home.shellAliases = {
      gd = "git diff ";
      gdc = "git diff --cached";
      gl = "git log --graph --color --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      gst = "git status ";
      gsa = "git stash push ";
      gsr = "git stash pop ";
      gsl = "git stash list ";
      gc = "git commit ";
      gca = "git commit --amend ";
      gr = "git rebase ";
      gpa = "git pull --all";
      ga = "git add";
      gre = "git restore ";
      grs = "git restore --staged";
    };

    programs.git = {
      enable = true;
      userEmail = "kfearsoff@gmail.com";
      userName = "KFears";
      extraConfig = {
        init.defaultBranch = "main";
        merge.conflictStyle = "diff3";
        diff = {
          colorMoved = "default";
          sopsdiffer.textconv = "${pkgs.sops}/bin/sops -d";
        };
        sequence.editor = "${pkgs.git-interactive-rebase-tool}/bin/interactive-rebase-tool";
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
      delta = {
        enable = true;
        options = {
          navigate = true;
          line-numbers = true;
          syntax-theme = "base16";
          # side-by-side = true;
        };
      };
    };
  };
}
