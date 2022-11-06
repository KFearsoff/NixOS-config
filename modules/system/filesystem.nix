{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nixchad.filesystem;
in {
  options.nixchad.filesystem = {
    enable = mkEnableOption "filesystem";

    type = mkOption {
      type = types.enum ["ext4" "btrfs"];
      default = "btrfs";
    };
  };

  config = mkIf cfg.enable {
    services.btrfs.autoScrub.enable = (cfg.type == "btrfs");
  };
}
