{
  boot.loader.grub = {
    enable = true;
    version = 2;
    efiSupport = true;
    devices = [ "nodev" ];
  };
  # NixOS bootsplash
  boot.plymouth.enable = true;
}
