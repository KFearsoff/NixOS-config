{
  imports = [
    ./system
    ./common-services
    ./games
    ./gui
    ./private-services
    ./neovim
    ./niri
    ./cli
    ./sway
    ./reverse-proxy
  ];

  config.nixchad.system.enable = true;
}
