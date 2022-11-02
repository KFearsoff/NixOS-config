{
  inputs,
  username,
  pkgs,
  ...
}: {
  imports = [
    ./fzf.nix
    ./nix-index.nix
  ];

  config = {
    environment.systemPackages = with pkgs; [
      inputs.deploy-rs.defaultPackage.x86_64-linux
    ];
  };
}
