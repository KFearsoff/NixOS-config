{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
{
  options.nixchad.gui = {
    pipewire = mkEnableOption "pipewire and related packages";
  };

  config = mkIf config.nixchad.gui.pipewire {
    environment.systemPackages = with pkgs; [
      pavucontrol
      pulseaudio
    ];

    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
      extraConfig = {
        pipewire = {
          "10-better-defaults" = {
            "context.properties" = {
              "default.clock.rate" = 48000;
              "default.clock.allowed-rates" = [ 48000 ];
              "default.clock.quantum" = 800;
              "default.clock.min-quantum" = 512;
              "default.clock.max-quantum" = 1024;
            };
          };
        };
        pipewire-pulse = {
          "10-better-defaults" = {
            "pulse.properties" = {
              "pulse.default.req" = "800/48000";
              "pulse.min.req" = "512/48000";
              "pulse.max.req" = "1024/48000";
            };
          };
        };
      };
    };
  };
}
