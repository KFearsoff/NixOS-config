{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nixchad.utils;
in {
  options.nixchad.utils = {
    enable = mkEnableOption "utils";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs;
      [
        neofetch # the system won't boot without it
        ripgrep # alternative to grep
        fd # alternative to find
        nix-tree
        ncdu
      ]
      ++ optionals (config.nixchad.filesystem.enable && config.nixchad.filesystem.type == "btrfs") [
        btdu
      ]
      ++ optionals (config.nixchad.filesystem.enable && config.nixchad.filesystem.type == "ext4") [
        du-dust
        duf
      ];

    hm = {
      home = {
        packages = with pkgs; [
          tokei # list used programming languages
          ascii-image-converter
        ];
      };

      programs = {
        tealdeer = {
          enable = true;
          settings = {
            updates = {
              auto_update = true;
              auto_update_interval_hours = 24;
            };
          };
        };

        direnv = {
          enable = true;
          nix-direnv.enable = true;
        };
      };
    };
  };
}
