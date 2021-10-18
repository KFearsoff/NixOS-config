{ pkgs, ... }: {
  imports = [
#    ./i3.nix
    ./swap-caps-esc.nix
    ./fonts.nix
    ./autolock.nix
    ./keymap.nix
#    ./gtk.nix
  ];

  environment.systemPackages = with pkgs; [
    xorg.xmessage
  ];

  # Enable the X11 windowing system.
  services.xserver =
    {
      enable = true;
      displayManager.lightdm = {
        enable = true;
        greeter.enable = true;
        greeters.gtk = {
          iconTheme.package = pkgs.paper-icon-theme;
          iconTheme.name = "Paper";
          theme.package = pkgs.adapta-gtk-theme;
          theme.name = "Adapta-Nokto-Eta";
        };
      };
      windowManager.i3 = {
        enable = true;
        package = pkgs.i3-gaps;
      };
      desktopManager.plasma5.enable = true;
    };
}
