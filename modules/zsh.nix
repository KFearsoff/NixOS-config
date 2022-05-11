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

          ".." = "cd ..";
          "..." = "cd ../..";
          ".2" = "cd ../..";
          ".3" = "cd ../../..";
          ".4" = "cd ../../../..";
          ".5" = "cd ../../../../..";
          ".6" = "cd ../../../../../..";

          ls = "exa -lg --color=always --group-directories-first ";
          la = "exa -lag --color=always --group-directories-first ";
          lt = "exa -lagT --color=always --group-directories-first ";
          "l." = "exa -a | egrep \"^\\.\"";

          grep = "grep --color=auto";
          egrep = "egrep --color=auto";
          fgrep = "fgrep --color=auto";

          md = "mkdir -vp ";
          ps = "procs ";
          cat = "batcopy";
          tail = "battail";

          gco = "git checkout";
          gst = "git status";
          newsboat = "newsboat -q";
        };
        initExtra = ''
          # Search Files and Edit
          fe() {
            rg --files ''${1:-.} | fzf --preview 'bat -fp {}' | xargs $EDITOR
          }
          # Autocomplete "flake" to "flake.nix"
            zstyle ":completion:*:*:vim:*:*files" ignored-patterns '*.lock'
          # Highlight --help with bat 
          help() {
              "$@" --help 2>&1 | bat -pl help
            }
          batcopy() {
            bat "$@" | wl-copy
            }
          battail() {
              tail -f "$@" | bat --paging=never -pl log
            }
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

