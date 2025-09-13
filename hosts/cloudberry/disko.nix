{
  disks ? [ "/dev/sda" ],
  ...
}:
{
  disko.devices.disk."sda" = {
    type = "disk";
    device = builtins.elemAt disks 0;
    content = {
      type = "gpt";
      partitions = {
        bios = {
          priority = 1;
          start = "0";
          end = "1M";
          type = "EF02";
        };
        boot = {
          priority = 2;
          start = "1M";
          end = "128MiB";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        root = {
          priority = 3;
          start = "128MiB";
          end = "100%";
          content = {
            type = "btrfs";
            extraArgs = "--label root";
            subvolumes = {
              "/root" = {
                mountpoint = "/";
                mountOptions = [
                  "compress-force=zstd"
                  "noatime"
                ];
              };
              "/home-nixchad" = {
                mountpoint = "/home/nixchad";
                mountOptions = [
                  "compress-force=zstd"
                  "noatime"
                ];
              };
              "/nix" = {
                mountpoint = "/nix";
                mountOptions = [
                  "compress-force=zstd"
                  "noatime"
                ];
              };
              "/persist" = {
                mountpoint = "/persist";
                mountOptions = [
                  "compress-force=zstd"
                  "noatime"
                ];
              };
              "/secrets" = {
                mountpoint = "/secrets";
                mountOptions = [
                  "compress-force=zstd"
                  "noatime"
                ];
              };
            };
          };
        };
      };
    };
  };

  fileSystems."/persist".neededForBoot = true;
  fileSystems."/secrets".neededForBoot = true;
}
