{pkgs, ...}: {
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

    config.pipewire = {
      "context.properties" = {
        "default.clock.allowed-rates" = [48000 44100];
      };
    };
  };
}
