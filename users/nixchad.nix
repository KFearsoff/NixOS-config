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
    ../modules/vscodium.nix
    ../modules/mpv.nix
    ../modules/newsboat.nix
  ];
  config = {
    users.users."${username}" = {
      isNormalUser = true;
      extraGroups = [ "wheel" "libvirtd" "docker" "networkmanager" "video" ];
      initialPassword = "123";
    };
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.extraSpecialArgs = { inherit username; };
    home-manager.users."${username}" = {
      home.packages = with pkgs; [
        du-dust
        duf
      ];

      home.stateVersion = "22.05";
    };
  };
}
