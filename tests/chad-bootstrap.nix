{
  pkgs,
  nixosTest,
  ...
}:
nixosTest {
  name = "chad-bootstrap";

  nodes.machine = {
    pkgs,
    lib,
    ...
  }: {
    environment.systemPackages = let
      chad-bootstrap = pkgs.callPackage ../pkgs/chad-bootstrap.nix {
        disk = "/dev/vdb";
        user = "nixchad";
        install-host = "blackberry";
      };
    in [chad-bootstrap];

    virtualisation.emptyDiskImages = [4096]; # 4 gigabytes
  };

  testScript = ''
    machine.wait_for_unit("multi-user.target")
    print(machine.succeed("whereis chad-bootstrap"))
    print(machine.succeed("mkdir /mnt"))
    machine.shutdown()
  '';
}
