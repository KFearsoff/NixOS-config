{ lib, pkgs, zsh-autosuggestions, zsh-you-should-use, zsh-history-substring-search, zsh-nix-shell, ... }:

{
  enable = true;
  enableCompletion = true;
  history.expireDuplicatesFirst = true;
  history.extended = true;
  oh-my-zsh = {
    enable = true;
  };
  plugins = [
    {
      name = "zsh-autosuggestions";
      src = zsh-autosuggestions;
    }
    {
      name = "nix-zsh-completions";
      src = "${pkgs.nix-zsh-completions}/share/zsh/site-functions";
    }
    {
      name = "fast-syntax-highlighting";
      src = "${pkgs.zsh-fast-syntax-highlighting}/share/zsh-site-functions";
    }
    {
      name = "you-should-use";
      src = zsh-you-should-use;
    }
    {
      name = "zsh-history-substring-search";
      src = zsh-history-substring-search;
    }
  ];
}

