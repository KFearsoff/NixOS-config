{
  imports = [
    ../profiles/starship.nix
    ../profiles/zsh.nix
  ];

  config = {
    nixchad.neovim.enable = true;
    nixchad.cli.enable = true;
    nixchad.fzf.enable = true;
    nixchad.bat.enable = true;
    nixchad.nix-index.enable = true;
  };
}
