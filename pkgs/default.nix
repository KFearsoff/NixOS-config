{pkgs}: {
  chad-bootstrap = pkgs.callPackage ./chad-bootstrap.nix {};
  chad-bootstrap-test = pkgs.callPackage ../tests/chad-bootstrap.nix {};
  metadata-test = assert (import ../tests/metadata.nix {inherit (pkgs) lib;}) == []; ../tests/metadata.nix;
}
