{
  imports = [
    ../profiles/cli
    ../profiles/tty.nix
    ../profiles/starship.nix
    ../profiles/zsh.nix
    ../profiles/nushell
  ];

  config = {
    nixchad.neovim.enable = true;
    nixchad.cli.enable = true;
    nixchad.fzf.enable = true;
  };
}
