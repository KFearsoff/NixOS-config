{
  config,
  lib,
  username,
  pkgs,
  ...
}: with lib; let
  cfg = config.nixchad.vscodium;
in {
  options.nixchad.vscodium = {
    enable = mkEnableOption "vscodium";
  };

  config = {
    home-manager.users."${username}" = {
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
          ms-python.python
        ];

        userSettings = {
          workbench.colorTheme = "Dracula";
          nix.enableLanguageServer = true;
          files.autoSave = "afterDelay";
          editor.tabSize = 2;
          editor.tabCompletion = "on";
          editor.fontFamily = "'Iosevka', 'monospace', monospace";
          editor.fontLigatures = true;
          editor.formatOnSave = true;
          diffEditor.codeLens = true;
          workbench.enableExperiments = false;
          workbench.settings.enableNaturalLanguageSearch = false;
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
