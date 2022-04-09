{ lib, pkgs, username, zsh-autosuggestions, zsh-you-should-use, zsh-history-substring-search, ... }:

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
        autocd = true;
        history.expireDuplicatesFirst = true;
        history.extended = true;
        shellAliases = {
          ls = "exa -lg --color=always --group-directories-first";
          la = "exa -lag --color=always --group-directories-first";
          cat = "bat -p";
          md = "mkdir -vp";
          ps = "procs";
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
  };
}
