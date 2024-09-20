{
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "en_GB.UTF-8/UTF-8"
      "C.UTF-8/UTF-8"
    ];
    extraLocaleSettings = {
      LC_TIME = "en_GB.UTF-8";
    };
  };
  console.useXkbConfig = true;
  services.xserver.xkb = {
    layout = "us,ru";
    options = "caps:swapescape,grp:alt_shift_toggle,eurosign:e";
  };
}
