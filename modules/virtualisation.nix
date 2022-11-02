{
  pkgs,
  username,
  ...
}: {
  users.users."${username}".extraGroups = ["libvirtd"];
  home-manager.users."${username}".home.packages = with pkgs; [
    virt-manager
    virt-viewer
  ];

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/libvirt"
      "/var/lib/containers"
    ];
  };

  virtualisation.libvirtd.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };
}
