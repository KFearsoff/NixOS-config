{
  username,
  config,
  pkgs,
  ...
}: {
  programs.steam.enable = true;

  home-manager.users."${username}" = {
    home = {
      packages = with pkgs; [
        (lutris.override {extraPkgs = pkgs: with pkgs; [openssl wineWowPackages.full];})
      ];
    };
  };
}
