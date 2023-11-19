{
  lib,
  username,
  ...
}: {
  imports = [
    (lib.mkAliasOptionModule ["hm"] ["home-manager" "users" username])
  ];

  config = {
    users.users."${username}" = {
      isNormalUser = true;
      extraGroups = ["wheel" "networkmanager" "video"];
    };
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {inherit username;};
      verbose = true;
      sharedModules = [../modules/terminal.nix];
    };
    hm = {
      systemd.user.startServices = "sd-switch";
      xdg = {
        enable = true;
        userDirs = {
          enable = true;
          createDirectories = true;
        };
      };
      home.stateVersion = "23.05";
    };
  };
}
