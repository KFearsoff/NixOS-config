{pkgs}: {
  chad-bootstrap = pkgs.callPackage ./chad-bootstrap.nix {};
  chad-bootstrap-test = pkgs.callPackage ../tests/chad-bootstrap.nix {};
}
