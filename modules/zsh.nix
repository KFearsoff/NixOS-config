{ lib, pkgs, zsh-autosuggestions, zsh-you-should-use, zsh-history-substring-search, zsh-nix-shell, ... }:

{
  enable = true;
  enableAutosuggestions = true;
  enableCompletion = true;
  enableSyntaxHighlighting = true;
  autocd = true;
  history.expireDuplicatesFirst = true;
  history.extended = true;
  oh-my-zsh = {
    enable = true;
    theme = "dracula";
  };
  plugins = [
  {
	  name = "dracula";
	  src = pkgs.fetchFromGitHub {
	  owner = "dracula";
	  repo = "zsh";
	  rev = "086955abf00f0d95c18175dde66b4820a4c99f5d";
	  sha256 = "Dc4wEHf25I7jo/IP5WbRUbznobr0oK1cZGraCn3gwiw=";
  };
}
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
}

