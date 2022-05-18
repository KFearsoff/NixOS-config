{
  config,
  pkgs,
  username,
  ...
}: {
  imports = [
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
      extraGroups = ["wheel" "libvirtd" "docker" "networkmanager" "video"];
      passwordFile = config.sops.secrets.password.path;
    };
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.extraSpecialArgs = {inherit username;};
    home-manager.users."${username}".home.stateVersion = "22.05";
  };
}
