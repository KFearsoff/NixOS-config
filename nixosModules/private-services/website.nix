{
  inputs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.website;
in {
  options.nixchad.website = {
    enable = mkEnableOption "my personal website";
  };

  config = mkIf cfg.enable {
    environment.etc.website.source = "${inputs.website.packages.x86_64-linux.default}";

    services.nginx = {
      virtualHosts."nixalted.com" = {
        forceSSL = true;
        useACMEHost = "nixalted.com";

        locations."/" = {
          proxyPass = mkForce null;
          root = "/etc/website";
        };
      };
    };
  };
}
