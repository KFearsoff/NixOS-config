{
  lib,
  username,
  pkgs,
  ...
}: {
  imports = [
    (lib.mkAliasOptionModule ["hm"] ["home-manager" "users" username])
  ];

  config = {
    users.users."${username}" = {
      isNormalUser = true;
      extraGroups = ["wheel" "networkmanager" "video"];
      shell = pkgs.nushell;
      useDefaultShell = false;
    };
    home-manager = {
      extraSpecialArgs = {inherit username;};
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
      home.stateVersion = "23.11";
    };
  };
}
