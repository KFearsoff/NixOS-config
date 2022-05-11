{
  environment.persistence."/persist" = {
    directories = [
      "/var/lib/libvirt"
      "/var/lib/docker"
    ];
  };

  virtualisation.libvirtd.enable = true;
  virtualisation.docker.enable = true;
}
