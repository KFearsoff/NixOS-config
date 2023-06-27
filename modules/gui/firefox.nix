{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.nixchad.firefox;
  inherit (config) nur;
in {
  options.nixchad.firefox = {
    enable = mkEnableOption "firefox";
  };

  config = mkIf cfg.enable {
    hm = {
      programs.firefox = {
        enable = true;
        package = inputs.firefox.packages.${pkgs.system}.firefox-nightly-bin;
        profiles."default" = {
          extraConfig =
            builtins.readFile "${inputs.arkenfox}/user.js"
            + ''

              // OVERRIDES

              user_pref("browser.startup.page", 3); // 0102, session restore
              user_pref("privacy.clearOnShutdown.history", false); // 2811, don't clear history
              user_pref("privacy.resistFingerprinting.letterboxing", false); // 4504, I hate the margins

              lockPref("signon.rememberSignons", false) // bitwarden is used instead
              lockPref("toolkit.legacyUserProfileCustomizations.stylesheets", true) // enable CSS styling
              lockPref("browser.tabs.inTitlebar", "0") // use native decoration
            '';

          userChrome = ''
            /* Hide horizontal tabs on top of the window */
            #main-window[tabsintitlebar="true"]:not([extradragspace="true"]) #TabsToolbar > .toolbar-items {
              opacity: 0;
              pointer-events: none;
            }
            #main-window:not([tabsintitlebar="true"]) #TabsToolbar {
              visibility: collapse !important;
            }
          '';

          extensions = [
            # recommended by arkenfox
            nur.repos.rycee.firefox-addons.ublock-origin
            nur.repos.rycee.firefox-addons.skip-redirect

            # optional recommended by arkenfox
            nur.repos.rycee.firefox-addons.multi-account-containers

            # extensions I like/need
            nur.repos.rycee.firefox-addons.bitwarden
            nur.repos.rycee.firefox-addons.dracula-dark-colorscheme
            nur.repos.rycee.firefox-addons.istilldontcareaboutcookies
            nur.repos.rycee.firefox-addons.privacy-redirect
            nur.repos.rycee.firefox-addons.tree-style-tab
          ];

          search = {
            force = true;
            default = "DuckDuckGo";
            order = ["DuckDuckGo"];
            engines = {
              "Amazon.com".metaData.hidden = true;
              "Bing".metaData.hidden = true;
              "Google".metaData.hidden = true;
              "Wikipedia (en)".metaData.alias = "@w";
            };
          };
        };
      };
    };
  };
}
