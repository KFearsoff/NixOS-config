{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
let
  cfg = config.nixchad.firefox;
  inherit (pkgs) nur;
in
{
  options.nixchad.firefox = {
    enable = mkEnableOption "firefox";
  };

  config = mkIf cfg.enable {
    hm = {
      stylix.targets.firefox.profileNames = [
        "default"
        "conferencing"
      ];

      programs.firefox = {
        enable = true;
        profiles = {
          "default" = {
            extraConfig =
              builtins.readFile "${inputs.arkenfox}/user.js"
              + ''

                // OVERRIDES

                user_pref("browser.startup.page", 3); // 0102, session restore
                user_pref("privacy.clearOnShutdown_v2.historyFormDataAndDownloads", false); // 2811, don't clear history; FF 128-135
                user_pref("privacy.clearOnShutdown_v2.browsingHistoryAndDownloads", false); // 2812, don't clear history; FF 136+
                user_pref("privacy.resistFingerprinting.letterboxing", false); // 4504, I hate the margins
                user_pref("webgl.disabled", false); // required for Zoom (also needs canvas exception)

                lockPref("signon.rememberSignons", false); // bitwarden is used instead
                lockPref("toolkit.legacyUserProfileCustomizations.stylesheets", true); // enable CSS styling
                lockPref("browser.tabs.inTitlebar", "0"); // use native decoration
                lockPref("media.ffmpeg.vaapi.enabled", true); // enable hardware video acceleration
              '';

            userChrome = ''
              /* Hide horizontal tabs on top of the window */
              #main-window #TabsToolbar {
                display: none;
              }
            '';

            extensions.packages = [
              # recommended by arkenfox
              nur.repos.rycee.firefox-addons.ublock-origin
              nur.repos.rycee.firefox-addons.skip-redirect

              # optional recommended by arkenfox
              nur.repos.rycee.firefox-addons.multi-account-containers

              # extensions I like/need
              nur.repos.rycee.firefox-addons.bitwarden
              nur.repos.rycee.firefox-addons.istilldontcareaboutcookies
              nur.repos.rycee.firefox-addons.tree-style-tab
              nur.repos.rycee.firefox-addons.temporary-containers
            ];

            search = {
              force = true;
              default = "ddg";
              order = [ "ddg" ];
              engines = {
                "amazondotcom-us".metaData.hidden = true;
                "bing".metaData.hidden = true;
                "google".metaData.hidden = true;
                "wikipedia".metaData.alias = "@w";

                "Nix Packages" = {
                  urls = [
                    {
                      template = "https://search.nixos.org/packages";
                      params = [
                        {
                          name = "channel";
                          value = "unstable";
                        }
                        {
                          name = "type";
                          value = "packages";
                        }
                        {
                          name = "query";
                          value = "{searchTerms}";
                        }
                      ];
                    }
                  ];

                  icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  definedAliases = [ "@np" ];
                };

                "NixOS Options" = {
                  urls = [
                    {
                      template = "https://search.nixos.org/options";
                      params = [
                        {
                          name = "channel";
                          value = "unstable";
                        }
                        {
                          name = "type";
                          value = "packages";
                        }
                        {
                          name = "query";
                          value = "{searchTerms}";
                        }
                      ];
                    }
                  ];

                  icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                  definedAliases = [ "@no" ];
                };

                "NixOS Wiki" = {
                  urls = [ { template = "https://nixos.wiki/index.php?search={searchTerms}"; } ];
                  icon = "https://nixos.wiki/favicon.png";
                  updateInterval = 24 * 60 * 60 * 1000; # every day
                  definedAliases = [ "@nw" ];
                };
              };
            };
          };

          "conferencing" = {
            id = 1;

            extraConfig = ''
              // OVERRIDES

              lockPref("signon.rememberSignons", false); // bitwarden is used instead
              lockPref("toolkit.legacyUserProfileCustomizations.stylesheets", true); // enable CSS styling
              lockPref("browser.tabs.inTitlebar", "0"); // use native decoration
            '';

            userChrome = ''
              /* Hide horizontal tabs on top of the window */
              #main-window #TabsToolbar {
                display: none;
              }
            '';

            extensions.packages = [
              nur.repos.rycee.firefox-addons.ublock-origin
              nur.repos.rycee.firefox-addons.bitwarden
              nur.repos.rycee.firefox-addons.istilldontcareaboutcookies
            ];

            search = {
              force = true;
              default = "ddg";
              order = [ "ddg" ];
              engines = {
                "amazondotcom-us".metaData.hidden = true;
                "bing".metaData.hidden = true;
                "google".metaData.hidden = true;
                "wikipedia".metaData.alias = "@w";
              };
            };
          };
        };
      };
    };
  };
}
