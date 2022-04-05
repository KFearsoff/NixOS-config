{ inputs, config, lib, pkgs, zsh-autosuggestions, zsh-you-should-use, zsh-history-substring-search, zsh-nix-shell, username, ... }:

let
  args = {
    username = "${username}";
    inherit (inputs) nix-colors;
    inherit pkgs;
    inherit config;
    inherit lib;
  };
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    (import ../modules/colors.nix args)
    (import ../modules/sway args)
    (import ../modules/alacritty.nix args)
    (import ../modules/zsh.nix (args // { inherit zsh-autosuggestions zsh-you-should-use zsh-history-substring-search zsh-nix-shell; }))
    (import ../modules/gammastep.nix args)
    (import ../modules/starship.nix args)
    (import ../modules/common.nix args)
    (import ../modules/mako.nix args)
    (import ../modules/neovim args)
    (import ../modules/zathura.nix args)
    (import ../modules/waybar.nix args)
  ];
  config = {
    users.users."${username}" = {
      isNormalUser = true;
      extraGroups = [ "wheel" "libvirtd" "docker" "networkmanager" ];
      initialPassword = "test";
    };
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.extraSpecialArgs = { inherit username; };
    home-manager.users."${username}" = {
      home.packages = with pkgs; [
        lutris
        testdisk
      ];
        services.kanshi = {
        enable = true;
        profiles = {
          home = {
            outputs = [
              {
                criteria = "HDMI-A-1";
                status = "enable";
                position = "0,0";
              }
            ];
          };
        };
      };
    };
  };
}
