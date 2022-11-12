{ pkgs, nixosTest, ... }: nixosTest {
  name = "chad-bootstrap";

  nodes.machine = { pkgs, lib, ... }:
  {
    environment.systemPackages = with pkgs; [ (pkgs.callPackage ../pkgs/chad-bootstrap.nix {}) ];
  };

  testScript = ''
    machine.wait_for_unit("multi-user.target")
    print(machine.succeed("whereis chad-bootstrap"))
    machine.shutdown()
  '';
}
