{
  lib,
  writeShellApplication,
  cryptsetup,
  parted,
  btrfs-progs,
  disk ? null,
  user ? null,
  install-host ? null,
  ...
}:
with lib;
  writeShellApplication {
    name = "chad-bootstrap";

    runtimeInputs = [cryptsetup parted btrfs-progs];

    text = ''
      set -x

      # Workaround the nounset option
      ${optionalString (disk == null) "read -rp \"Enter the disk to install the system on: \" DISK"}
      ${optionalString (user == null) "read -rp \"Enter the user to be created with the system: \" USER"}
      ${optionalString (install-host == null) "read -rp \"Enter the host to be install on the system: \" INSTALL_HOST"}
      # Workaround the nounset option
      ${optionalString (disk != null) "DISK=${disk}"}
      ${optionalString (user != null) "USER=${user}"}
      ${optionalString (install-host != null) "INSTALL_HOST=${install-host}"}

      parted -a opt --script "$DISK" \
        mklabel gpt \
        mkpart primary fat32 0% 512MiB \
        mkpart primary 512MiB 100% \
        set 1 esp on \
        name 1 boot \
        name 2 root

      cryptsetup -q luksFormat /dev/disk/by-partlabel/root /dev/zero --keyfile-size=1
      cryptsetup luksOpen /dev/disk/by-partlabel/root crypt --key-file=/dev/zero --keyfile-size=1

      mkfs.fat -F 32 -n boot /dev/disk/by-partlabel/boot
      mkfs.btrfs -L root /dev/mapper/crypt

      mount -t btrfs /dev/mapper/crypt /mnt
      btrfs subvolume create /mnt/root
      btrfs subvolume create /mnt/home-"$USER"
      btrfs subvolume create /mnt/nix
      btrfs subvolume create /mnt/persist
      btrfs subvolume snapshot -r /mnt/root /mnt/root-blank
      btrfs subvolume snapshot -r /mnt/home-"$USER" /mnt/home-"$USER"-blank
      umount /mnt

      mount -o subvol=root,compress-force=zstd,noatime /dev/mapper/crypt /mnt
      mkdir -p /mnt/home/"$USER"
      mount -o subvol=home-"$USER",compress-force=zstd,noatime /dev/mapper/crypt /mnt/home/"$USER"
      mkdir /mnt/nix
      mount -o subvol=nix,compress-force=zstd,noatime /dev/mapper/crypt /mnt/nix
      mkdir /mnt/persist
      mount -o subvol=persist,compress-force=zstd,noatime /dev/mapper/crypt /mnt/persist

      mkdir /mnt/boot
      mount /dev/disk/by-label/boot /mnt/boot

      nixos-install --root /mnt --flake github:KFearsoff/NixOS-config#"$INSTALL_HOST"
    '';
  }
