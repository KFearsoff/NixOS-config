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
  #networking.nameservers = ["100.100.100.100" "8.8.8.8" "8.8.4.4" "1.1.1.1"];
  #networking.search = ["kfearsoff.gmail.com.beta.tailscale.net"];
  #networking.networkmanager.dns = "unbound";
  #networking.networkmanager.dns = "dnsmasq";
  #services.stubby.enable = true;
  #services.stubby.settings = (builtins.fromJSON (builtins.readFile (pkgs.runCommandLocal "stubby-to-json" { nativeBuildInputs = [ pkgs.yq]; } "yq -r -j < ${pkgs.stubby}/etc/stubby/stubby.yml > $out"))) // {listen_addresses = ["127.0.0.1@53000" "0::1@53000"];};

  #networking.networkmanager.dns = "none";
  #networking.resolvconf.extraOptions = ["trust-ad"];
  #services.dnsmasq.enable = true;
  #services.dnsmasq.extraConfig = ''
  #  no-resolv
  #  dnssec
  #  listen-address=::1,127.0.0.1
  #  cache-size=400
  #  conf-file=${pkgs.dnsmasq}/share/dnsmasq/trust-anchors.conf
  #'';
  #services.dnsmasq.servers = ["9.9.9.9" "8.8.8.8" "1.1.1.1"];

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
