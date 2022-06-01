{
  username,
  pkgs,
  lib,
  ...
}: let
  myteam = pkgs.callPackage ../../pkgs/myteam.nix {
    inherit lib;
    inherit
      (pkgs)
      stdenvNoCC
      fetchurl
      autoPatchelfHook
      freetype
      fontconfig
      ;
    inherit
      (pkgs.xorg)
      libXcursor
      libXcomposite
      libXdamage
      libXext
      libXinerama
      libXrandr
      ;
  };
in {
  home-manager.users."${username}" = {
    home.packages = [myteam];
    xdg.desktopEntries = {
      myteam = rec {
        name = "My Team";
        genericName = "Corporate Messenger";
        exec = "env QT_QPA_PLATFORM=xcb ${myteam}/bin/myteam";
      };
    };
  };
}
