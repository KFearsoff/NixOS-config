{ nix-colors, username, ... }:

{
  config.home-manager.users."${username}" = {
    imports = [ nix-colors.homeManagerModule ];
    config.colorscheme = nix-colors.colorSchemes.dracula;
  };
}
