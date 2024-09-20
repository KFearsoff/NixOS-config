{
  inputs,
  config,
  lib,
  username,
  pkgs,
  ...
}:
let
  inherit (lib) mkAliasOptionModule optionalAttrs;
in
{
  imports = [
    (mkAliasOptionModule [ "hm" ] [
      "home-manager"
      "users"
      username
    ])
  ];

  config = {
    users.users."${username}" =
      {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
          "video"
        ];
      }
      // (optionalAttrs config.hm.nixchad.nushell.enable {
        shell = pkgs.nushell;
        useDefaultShell = false;
      });
    home-manager = {
      extraSpecialArgs = {
        inherit inputs username;
      };
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
