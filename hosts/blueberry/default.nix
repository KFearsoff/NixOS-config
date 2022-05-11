{ inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./kanshi.nix
    ../common
    ../common/virtualisation.nix
    ../common/nixconf.nix
    ../common/pipewire.nix
    ../common/syncthing.nix
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-pc-laptop-ssd
    inputs.hardware.nixosModules.common-pc-laptop
    inputs.hardware.nixosModules.common-pc-laptop-acpi_call
  ];

  networking = {
    hostName = "blueberry"; # Define your hostname.
  };

  environment.persistence."/persist" = {
    directories = [
      "/etc/lvm/archive"
      "/etc/lvm/backup"
    ];
  };

  programs.dconf.enable = true;
  programs.light.enable = true;

  services.printing.enable = true;
  users.mutableUsers = false;
  boot.loader.systemd-boot = {
    enable = true;
    consoleMode = "max";
    editor = false;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  services.logind = {
    lidSwitch = "suspend";
    lidSwitchExternalPower = "ignore";
  };
}

