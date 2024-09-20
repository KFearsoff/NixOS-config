{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.nixchad.games;

  # https://libredd.it/r/leagueoflinux/comments/ultxfo/cannot_enter_in_game_after_champ_select_error/
  league-launcher-script = pkgs.writeShellScriptBin "league-launcher-script" ''
    clean_up() {
      echo "Cleaning up, setting abi.vsyscall32 to 1"
      sudo -S sysctl -w abi.vsyscall32=1
      exit 0
    }

    main() {
      trap 'clean_up' INT
      while [[ $exit_status_pass != 0 ]]
      do
        sudo sysctl -w abi.vsyscall32=0
        if [ $? -eq 0 ]; then
          exit_status_pass=0
        fi
      done

      [[ $exit_status_pass == 0 ]] && {
        echo "Starting League of Legends . . ."
        env LUTRIS_SKIP_INIT=1 ${pkgs.lutris}/bin/lutris lutris:rungame/league-of-legends
      }

      clean_up
    }

    main
  '';
in
{
  options.nixchad.games = {
    league-of-legends.enable = mkEnableOption "League of Legends";
  };

  config = mkIf cfg.league-of-legends.enable {
    nixchad.games.lutrisPackages = with pkgs; [
      openssl
      wineWowPackages.full
    ];

    hm.xdg.desktopEntries = {
      LoL = {
        name = "League of Legends";
        genericName = "A Riot game";
        exec = "${league-launcher-script}/bin/league-launcher-script";
      };
    };
  };
}
