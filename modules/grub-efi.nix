{
#  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    version = 2;
    efiSupport = true;
    device = "nodev";
    useOSProber = true;
    enableCryptodisk = true;
    efiInstallAsRemovable = true;
  };
  # NixOS bootsplash
  boot.plymouth.enable = true;
}
