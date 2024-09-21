{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.nixchad.vscodium;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.nixchad.vscodium = {
    enable = mkEnableOption "vscodium" // {
      default = config.nixchad.gui.enable;
    };
  };

  config = mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;

      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        mads-hartmann.bash-ide-vscode
        rust-lang.rust-analyzer
      ];

      userSettings = {
        workbench = {
          enableExperiments = false;
          settings.enableNaturalLanguageSearch = false;
        };
        nix.enableLanguageServer = true;
        files.autoSave = "afterDelay";
        editor = {
          tabSize = 2;
          tabCompletion = "on";
          fontFamily = "'Iosevka', 'monospace', monospace";
          fontLigatures = true;
          formatOnSave = true;
        };
        diffEditor.codeLens = true;
        update.mode = "manual";
        update.showReleaseNotes = false;
        json.schemaDownload.enable = false;
        typescript.disableAutomaticTypeAcquisition = true;
        extensions.autoCheckUpdates = false;
        extensions.autoUpdate = false;
        npm.fetchOnlinePackageInfo = false;
        redhat.telemetry.enabled = false;
        explorer.confirmDelete = false;
        git.confirmSync = false;
        files.trimTrailingWhitespace = true;
        rust-analyzer.checkOnSave.command = "clippy";
      };
    };
  };
}
