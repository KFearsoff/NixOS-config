{ username, nix-colors, ... }:

{
  config.home-manager.users."${username}" = {
    imports = [ nix-colors.homeManagerModule ];
    config.colorscheme = nix-colors.colorSchemes.dracula;
  };
}
