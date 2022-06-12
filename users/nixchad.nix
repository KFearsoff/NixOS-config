{
  config,
  pkgs,
  username,
  ...
}: {
  users.users."${username}" = {
    isNormalUser = true;
    extraGroups = ["wheel" "libvirtd" "networkmanager" "video" "wireshark"];
    passwordFile = config.sops.secrets.password.path;
  };
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = {inherit username;};
  home-manager.verbose = true;
  home-manager.sharedModules = [../modules/terminal.nix];
  home-manager.users."${username}" = {
    systemd.user.startServices = "sd-switch";
    xdg = {
      enable = true;
      userDirs = {
        enable = true;
        createDirectories = true;
      };
    };
    home.stateVersion = "22.05";
  };
}
