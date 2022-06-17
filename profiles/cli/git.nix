{
  username,
  pkgs,
  ...
}: {
  home-manager.users."${username}" = {
    home.packages = [
      pkgs.git-filter-repo
    ];

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
