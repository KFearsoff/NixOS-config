{
  inputs,
  username,
  pkgs,
  ...
}: {
  imports = [
    ./bat.nix
    ./fzf.nix
    ./git.nix
    ./nix-index.nix
  ];

  config = {
    environment.systemPackages = with pkgs; [
      minikube
      kubectl
      kubernetes-helm
      inputs.deploy-rs.defaultPackage.x86_64-linux
    ];

    home-manager.users."${username}" = {
      home = {
        file = {
          # Patch Minikube kvm2 driver, see https://github.com/NixOS/nixpkgs/issues/115878
          ".minikube/bin/docker-machine-driver-kvm2".source = "${pkgs.docker-machine-kvm2}/bin/docker-machine-driver-kvm2";
        };
      };
    };
  };
}
