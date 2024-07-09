{pkgs}: {
  chad-bootstrap = pkgs.callPackage ./chad-bootstrap.nix {};
  chad-bootstrap-test = pkgs.callPackage ../tests/chad-bootstrap.nix {};
  terraform-mpl = (pkgs.callPackage ./terraform-mpl.nix {}).terraform_1;
  packer-mpl = pkgs.callPackage ./packer-mpl.nix {};
}
