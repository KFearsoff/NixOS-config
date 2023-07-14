{
  inputs,
  username,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./kanshi.nix
    (import ./disko.nix {})
    inputs.disko.nixosModules.disko
    inputs.hardware.nixosModules.common-gpu-amd
    inputs.hardware.nixosModules.common-cpu-amd-pstate
    inputs.hardware.nixosModules.common-pc-laptop-ssd
    inputs.hardware.nixosModules.common-pc-laptop
    inputs.hardware.nixosModules.common-hidpi
  ];
  services.thermald.enable = true;

  users.users."${username}".passwordFile = "/secrets/nixchad-password";

  # Focusrite Scarlett 2i2
  boot.extraModprobeConfig = ''
    options snd_usb_audio vid=0x1235 pid=0x8210 device_setup=1
  '';

  nixchad.boot.bootloader = "systemd-boot";
  nixchad.smartctl-exporter.devices = ["/dev/nvme0n1"];
  nixchad.waybar.battery = true;
  programs.light.enable = true;
  nixchad.restic.usb-backups = true;

  nixchad.impermanence.presets = {
    enable = true;
    essential = true;
    system = true;
    services = true;
  };

  networking.networkmanager.unmanaged = ["interface-name:tailscale0" "interface-name:tun*"];
  zramSwap.enable = true;
}
