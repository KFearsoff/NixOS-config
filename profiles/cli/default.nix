{
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
      neofetch # the system won't boot without it
      wget
      htop
      ripgrep # alternative to grep
      fd # alternative to find
      nix-prefetch-github
      tldr
      du-dust
      duf
      jq
      xdg-utils
      nix-tree
      dig
      mtr
      nmap
    ];

    home-manager.users."${username}" = {
      home = {
        packages = with pkgs; [
          bottom # htop alternative
          exa # alternative to ls
          tokei # list used programming languages
          procs # alternative to ps
          shellcheck
          ascii-image-converter
          wireguard-tools
          mullvad-vpn
          openconnect
        ];
      };

      programs = {
        direnv = {
          enable = true;
          nix-direnv.enable = true;
        };
      };
    };
  };
}
