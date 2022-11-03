{
  imports = [
    ../profiles/greetd.nix
    ../profiles/mako.nix
    ../profiles/theming.nix
    ../profiles/sway
  ];

  config.nixchad = {
    sway.enable = true;
  };
}
