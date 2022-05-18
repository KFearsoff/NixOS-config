{
  username,
  pkgs,
  ...
}: {
  imports = [
    ./bat.nix
    ./fzf.nix
    ./git.nix
  ];

  config.home-manager.users."${username}" = {
    home = {
      packages = with pkgs; [
        neofetch
        gnumake
        unzip
        htop
        bottom # htop alternative
        ripgrep # alternative to grep
        fd # alternative to find
        exa # alternative to ls
        tokei # list used programming languages
        procs # alternative to ps
        nix-prefetch-github
        statix
        shellcheck
        tldr
        ascii-image-converter
        rnix-lsp
        wireguard-tools
        du-dust
        duf
        jq
        xdg-utils
        mullvad-vpn
        openconnect
        sops
      ];
    };
    programs = {
      nix-index.enable = true;

      direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
      };
    };
  };
}
