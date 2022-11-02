{
  imports = [
    ../profiles/cli
    ../profiles/colors.nix
    ../profiles/tty.nix
    ../profiles/starship.nix
    ../profiles/zsh.nix
    ../profiles/nushell
  ];

  config = {
    nixchad.neovim.enable = true;
    nixchad.cli.enable = true;
  };
}
