{ pkgs }:
{
  chad-bootstrap = pkgs.callPackage ./chad-bootstrap.nix { };
  chad-bootstrap-test = pkgs.callPackage ../tests/chad-bootstrap.nix { };
  terraform-mpl = (pkgs.callPackage ./terraform-mpl.nix { }).terraform_1;
  packer-mpl = pkgs.callPackage ./packer-mpl.nix { };
  bee-movie-script = pkgs.callPackage ./bee-movie-script.nix { };
  brave-new-world = pkgs.callPackage ./brave-new-world.nix { };
  modest-proposal = pkgs.callPackage ./modest-proposal.nix { };
  orwell-1984 = pkgs.callPackage ./orwell-1984.nix { };
}
