{
  imports = [
    ../profiles/sway
  ];

  config.nixchad = {
    sway.enable = true;
    waybar.enable = true;
    greetd.enable = true;
    mako.enable = true;
  };
}
