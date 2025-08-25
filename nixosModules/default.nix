{
  imports = [
    ./system
    ./common-services
    ./games
    ./gui
    ./private-services
    ./neovim
    ./cli
    ./sway
    ./reverse-proxy
  ];

  config.nixchad.system.enable = true;
}
