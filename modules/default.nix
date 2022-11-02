{
  imports = [
    ./system
    ./common-services
    ./games
    ./gui
    ./private-services
    ./neovim
    ./cli
  ];

  config.nixchad = {
    system.enable = true;
    impermanence.enable = true;
    networking.enable = true;
    boot.enable = true;
    filesystem.enable = true;
  };
}
