{pkgs, ...}: let
  exa = "${pkgs.eza}/bin/eza";
in {
  hm = {
    home.shellAliases = {
      sudo = "sudo -E "; # enable aliases when using sudo
      su = "sudo -i";

      ls = "${exa} -lg --color=always --group-directories-first ";
      la = "${exa} -lag --color=always --group-directories-first ";
      lt = "${exa} -lagT --color=always --group-directories-first ";
      "l." = "${exa} -a | egrep \"^\\.\" ";

      grep = "grep --color=auto ";
      egrep = "egrep --color=auto ";
      fgrep = "fgrep --color=auto ";

      md = "mkdir -vp ";
      ps = "${pkgs.procs}/bin/procs ";
    };
  };
}
