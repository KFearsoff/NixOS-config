{ inputs, config, lib, pkgs, username, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ../modules/colors.nix
    ../modules/sway
    ../modules/alacritty.nix
    ../modules/zsh.nix
    ../modules/gammastep.nix
    ../modules/starship.nix
    ../modules/common.nix
    ../modules/mako.nix
    ../modules/neovim
    ../modules/zathura.nix
    ../modules/waybar.nix
  ];
  config = {
    users.users."${username}" = {
      isNormalUser = true;
      extraGroups = [ "wheel" "libvirtd" "docker" "networkmanager" "video" ];
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
    };
  };
}
