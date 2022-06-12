{
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
