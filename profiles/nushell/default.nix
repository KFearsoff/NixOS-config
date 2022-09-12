{
  username,
  inputs,
  pkgs,
  ...
}: {
  home-manager.users."${username}" = {
    programs.nushell = {
      enable = true;
      configFile.source = ./config.nu;
      envFile.source = ./env.nu;
    };
  };
}
