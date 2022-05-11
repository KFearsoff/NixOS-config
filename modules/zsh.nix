{ inputs, pkgs, username, ... }:

{
  config = {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
    };
    users.users."${username}".shell = pkgs.zsh;

    home-manager.users."${username}" = {
      programs.zsh = {
        enable = true;
        enableAutosuggestions = true;
        enableCompletion = true;
        enableSyntaxHighlighting = true;
        history.expireDuplicatesFirst = true;
        history.extended = true;
        shellAliases = {
          sudo = "sudo "; # enable aliases when using sudo 
          newsboat = "newsboat -q";
          ls = "exa -lg --color=always --group-directories-first ";
          la = "exa -lag --color=always --group-directories-first ";
          cat = "bat -p ";
          md = "mkdir -vp ";
          ps = "procs ";
          ".." = "cd ..";
          "..." = "cd ../..";
          "...." = "cd ../../..";
          ".2" = "cd ../..";
          ".3" = "cd ../../..";
          ".4" = "cd ../../../..";
          ".5" = "cd ../../../../..";
          ".6" = "cd ../../../../../..";
          g = "git";
          gco = "git checkout";
          gst = "git status";
        };
        initExtra = ''
          # Search Files and Edit
          fe() {
            rg --files ''${1:-.} | fzf --preview 'bat -f {}' | xargs $EDITOR
          }
            zstyle ":completion:*:*:vim:*:*files" ignored-patterns '*.lock'
        '';
        plugins = [
          {
            name = "you-should-use";
            src = inputs.zsh-you-should-use;
          }
        ];
      };
    };
  };
}

