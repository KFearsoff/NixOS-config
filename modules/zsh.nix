{ lib, pkgs, username, zsh-autosuggestions, zsh-you-should-use, zsh-history-substring-search, zsh-nix-shell, ... }:

{
  config.home-manager.users."${username}" = {
    programs.zsh = {
  enable = true;
  enableAutosuggestions = true;
  enableCompletion = true;
  enableSyntaxHighlighting = true;
  autocd = true;
  history.expireDuplicatesFirst = true;
  history.extended = true;
  shellAliases = {
    ls = "exa";
    cat = "bat -p";
    l = "exa -la";
  };
  plugins = [
#    {
#      name = "zsh-powerlevel10k";
#      src = pkgs.zsh-powerlevel10k;
#      file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
#    }
#    {
#      name = "powerlevel10k-config";
#      src = lib.cleanSource ./p10k-config;
#      file = "p10k.zsh";
#    }
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
      src = "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions";
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
};
};
}

