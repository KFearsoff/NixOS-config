{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.nixchad.filesystem;
in
{
  options.nixchad.filesystem = {
    enable = mkEnableOption "filesystem";

    type = mkOption {
      type = types.enum [
        "ext4"
        "btrfs"
      ];
      default = "btrfs";
    };
  };

  config = mkIf (cfg.enable && cfg.type == "btrfs") {
    services.btrfs.autoScrub.enable = true;
    services.btrfs.autoScrub.fileSystems = [ "/" ];
  };
}
