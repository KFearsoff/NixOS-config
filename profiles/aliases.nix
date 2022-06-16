{
  username,
  pkgs,
  lib,
  ...
}: let
  exa = "${pkgs.exa}/bin/exa";
in {
  home-manager.users."${username}" = {config, ...}: {
    home.shellAliases = {
      sudo = "sudo -E "; # enable aliases when using sudo
      su = "sudo -i";
      ssh = lib.mkIf (config.terminal.enable && config.terminal.package == pkgs.kitty) "${pkgs.kitty}/bin/kitty +kitten ssh ";

      ".." = "cd ..";
      "..." = "cd ../..";
      ".2" = "cd ../..";
      ".3" = "cd ../../..";
      ".4" = "cd ../../../..";
      ".5" = "cd ../../../../..";
      ".6" = "cd ../../../../../..";

      ls = "${exa} -lg --color=always --group-directories-first ";
      la = "${exa} -lag --color=always --group-directories-first ";
      lt = "${exa} -lagT --color=always --group-directories-first ";
      "l." = "${exa} -a | egrep \"^\\.\" ";

      grep = "grep --color=auto ";
      egrep = "egrep --color=auto ";
      fgrep = "fgrep --color=auto ";

      md = "mkdir -vp ";
      ps = "${pkgs.procs}/bin/procs ";
      cat = "batcopy ";
      tail = "battail ";

      gd = "git diff ";
      gdc = "git diff --cached";
      gl = "git log --graph --color --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      gst = "git status ";
      gsa = "git stash push ";
      gsr = "git stash pop ";
      gsl = "git stash list ";
      gc = "git commit ";
      gr = "git rebase ";
      gpa = "git pull --all";
      ga = "git add";
      gre = "git restore ";
      grs = "git restore --staged";
      newsboat = "newsboat -q ";
    };
  };
}
