{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.nixchad.vscodium;
in {
  options.nixchad.vscodium = {
    enable = mkEnableOption "vscodium";
  };

  config = mkIf cfg.enable {
    hm = {
      programs.vscode = {
        enable = true;
        package = pkgs.vscodium;

        extensions = with pkgs.vscode-extensions; [
          dracula-theme.theme-dracula
          hashicorp.terraform
          jnoortheen.nix-ide
          arrterian.nix-env-selector
          b4dm4n.vscode-nixpkgs-fmt
          mads-hartmann.bash-ide-vscode
          haskell.haskell
          # ms-python.python
        ];

        userSettings = {
          workbench = {
            colorTheme = "Dracula";
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
        };
      };
    };
  };
}
