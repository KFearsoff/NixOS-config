{
  config,
  lib,
  pkgs,
  username,
  ...
}:
with lib; let
  cfg = config.nixchad.debug;
in {
  options.nixchad.debug = {
    enable = mkEnableOption "debug utilities";
  };

  config = mkIf cfg.enable {
    programs.mtr.enable = true;
    programs.wireshark.enable = true;
    users.users."${username}".extraGroups = ["wireshark"];

    environment.systemPackages = with pkgs; [
      htop
      nix-prefetch-github
      dig
      nmap
      killall
      speedtest-cli
    ];
  };
}
