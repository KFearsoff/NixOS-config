{
  disks ? [ "/dev/sda" ],
  ...
}:
{
  disko.devices.disk."sda" = {
    type = "disk";
    device = builtins.elemAt disks 0;
    content = {
      type = "table";
      format = "gpt";
      partitions = [
        {
          name = "bios";
          start = "0";
          end = "1M";
          flags = [ "bios_grub" ];
        }
        {
          name = "boot";
          start = "1M";
          end = "128MiB";
          fs-type = "fat32";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        }
        {
          name = "root";
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
        }
      ];
    };
  };

  fileSystems."/persist".neededForBoot = true;
  fileSystems."/secrets".neededForBoot = true;
}
