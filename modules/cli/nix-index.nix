{
  config,
  lib,
  pkgs,
  username,
  ...
}:
# https://libredd.it/r/NixOS/comments/uqfw3k/an_automaticallyupdated_nixindex/
# https://gist.github.com/InternetUnexplorer/58e979642102d66f57188764bbf11701
with lib; let
  cfg = config.nixchad.nix-index;
  nix-index-autoupdate = pkgs.writeShellScriptBin "nix-index-autoupdate" ''
    set -euo pipefail
    mkdir -p ~/.cache/nix-index && cd ~/.cache/nix-index
    filename="index-x86_64-$(uname | tr A-Z a-z)"
    # Delete partial downloads
    [ -f files ] || rm -f $filename
    wget -q -N https://github.com/Mic92/nix-index-database/releases/latest/download/$filename
    ln -f $filename files
  '';
in {
  options.nixchad.nix-index = {
    enable = mkEnableOption "nix-index";
  };

  config = mkIf cfg.enable {
    home-manager.users."${username}" = {
      programs.nix-index.enable = true;

      systemd.user.services.nix-index-update = {
        Unit = {Description = "Update nix-index";};
        Service = {ExecStart = "${nix-index-autoupdate}/bin/nix-index-autoupdate";};
      };

      systemd.user.timers.nix-index-update = {
        Unit = {Description = "Update nix-index";};
        Timer = {
          OnCalendar = "daily";
          Unit = "nix-index-update.service";
        };
        Install = {WantedBy = ["timers.target"];};
      };
    };
  };
}
