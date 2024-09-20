{
  disks ? [ "/dev/nvme0n1" ],
  ...
}:
{
  disko.devices.disk."nvme0n1" = {
    type = "disk";
    device = builtins.elemAt disks 0;
    content = {
      type = "table";
      format = "gpt";
      partitions = [
        {
          name = "ESP";
          start = "1MiB";
          end = "512MiB";
          bootable = true;
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        }
        {
          name = "root";
          start = "512MiB";
          end = "100%";
          content = {
            type = "luks";
            name = "crypted";
            extraOpenArgs = [
              "--allow-discards"
              "--perf-no_read_workqueue"
              "--perf-no_write_workqueue"
            ];
            keyFile = "/tmp/secret.key";
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
        }
      ];
    };
  };

  fileSystems."/persist".neededForBoot = true;
  fileSystems."/secrets".neededForBoot = true;
}
