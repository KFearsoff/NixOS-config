{
  inputs,
  lib,
  pkgs,
  username,
  ...
}: {
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
  programs.openvpn3.enable = true;
  services.mullvad-vpn.enable = true;

  sops.secrets.password = {
    sopsFile = ../../secrets/blueberry/default.yaml;
    neededForUsers = true;
  };
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_13;
  };
  networking.extraHosts = ''
    10.220.32.224 vcenter.lab.itkey.com
    192.168.1.100 blackberry
    10.10.30.9 keycloak-overcloud9.private.infra.devmail.ru
    10.10.30.9 overcloud9.private.infra.devmail.ru
    10.10.30.9 sso-overcloud9.private.infra.devmail.ru
    10.10.30.9 admin-overcloud9.private.infra.devmail.ru
    10.10.30.31 deploy
    10.10.30.191 box2
  '';

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  networking.hostName = "blueberry"; # Define your hostname.

  environment.persistence."/persist" = {
    directories = [
      "/etc/lvm/archive"
      "/etc/lvm/backup"
    ];
  };

  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns = true;
  };

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
