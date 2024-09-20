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
    };
  };
}
