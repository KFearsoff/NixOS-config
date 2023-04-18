{
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = ["en_US.UTF-8/UTF-8" "en_GB.UTF-8/UTF-8"];
    extraLocaleSettings = {
      LC_TIME = "en_GB.UTF-8";
    };
  };
  console.useXkbConfig = true;
  services.xserver = {
    layout = "us,ru";
    xkbOptions = "caps:swapescape,grp:alt_shift_toggle,eurosign:e";
  };
}
