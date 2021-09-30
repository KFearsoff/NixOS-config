{ pkgs, ... }: {
  imports = [
#    ./i3.nix
    ./swap-caps-esc.nix
    ./fonts.nix
    ./autolock.nix
#    ./gtk.nix
  ];

  environment.systemPackages = with pkgs; [
    xorg.xmessage
  ];

  services.xserver = {
    enable = true;
  };
}
