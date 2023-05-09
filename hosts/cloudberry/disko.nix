{
  disko.devices.disk."sda" = {
    type = "disk";
    device = "/dev/sda";
    content = {
      type = "table";
      format = "gpt";
      partitions = [
        {
          name = "ESP";
          start = "1MiB";
          end = "128MiB";
          fs-type = "fat32";
          bootable = true;
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
            type = "luks";
            name = "crypted";
            extraOpenArgs = ["--allow-discards" "--perf-no_read_workqueue" "--perf-no_write_workqueue"];
            # Ensure there's no newline at the end: `echo -n "password" > /tmp/secret.key`
            keyFile = "/tmp/secret.key";
            content = {
              type = "btrfs";
              subvolumes = {
                "/root" = {
                  mountpoint = "/";
                  mountOptions = ["compress-force=zstd" "noatime"];
                };
                "/home-nixchad" = {
                  mountpoint = "/home/nixchad";
                  mountOptions = ["compress-force=zstd" "noatime"];
                };
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = ["compress-force=zstd" "noatime"];
                };
                "/persist" = {
                  mountpoint = "/persist";
                  mountOptions = ["compress-force=zstd" "noatime"];
                };
                "/secrets" = {
                  mountpoint = "/secrets";
                  mountOptions = ["compress-force=zstd" "noatime"];
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
