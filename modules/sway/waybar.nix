{
  config,
  lib,
  pkgs,
  username,
  inputs,
  ...
}: with lib; let
  cfg = config.nixchad.waybar;
  inherit (config.hm) colorscheme;
in {
  options.nixchad.waybar = {
    enable = mkEnableOption "waybar";
    backlight = mkEnableOption "backlight info";
    battery = mkEnableOption "battery info";
  };

  config = mkIf cfg.enable {
    nixchad.waybar.backlight = mkDefault true;
    nixchad.waybar.battery = mkDefault false;

    hm = {
      programs.waybar = {
        # inspired by:
        # https://github.com/cjbassi/config/tree/master/.config/waybar
        enable = true;
        package = inputs.nixpkgs-old-waybar.legacyPackages.x86_64-linux.waybar;
        systemd.enable = true;
        systemd.target = "sway-session.target";
        settings = [
          {
            layer = "top";
            position = "top";

            modules-left = [
              "sway/workspaces"
              "sway/mode"
              "custom/right-arrow"
              "custom/right-arrow-inverse"
              "custom/right-arrow"
            ];
            modules-center = [
              "custom/left-arrow"
              "clock#1"
              "custom/left-arrow-inverse"
              "custom/left-arrow"
              "clock#2"
              "custom/right-arrow"
              "custom/right-arrow-inverse"
              "clock#3"
              "custom/right-arrow"
            ];
            modules-right = [
              "custom/left-arrow"
              "custom/left-arrow-inverse"
              "custom/left-arrow"
              "pulseaudio"
              "custom/left-arrow-inverse"
              "custom/left-arrow"
              "mpd"
              "custom/left-arrow-inverse"
              "custom/left-arrow"
              "network"
              "custom/left-arrow-inverse"
            ] ++ optionals cfg.backlight [
              "custom/left-arrow"
              "backlight"
              "custom/left-arrow-inverse"
            ] ++ [
              "custom/left-arrow"
              "sway/language"
              "custom/left-arrow-inverse"
            ] ++ optionals cfg.battery [
              "custom/left-arrow"
              "battery"
              "custom/left-arrow-inverse"
            ] ++ [
              "custom/left-arrow"
              "tray"
            ];

            "custom/left-arrow" = {
              format = "";
              tooltip = false;
            };
            "custom/left-arrow-inverse" = {
              format = "";
              tooltip = false;
            };
            "custom/right-arrow" = {
              format = "";
              tooltip = false;
            };
            "custom/right-arrow-inverse" = {
              format = "";
              tooltip = false;
            };
            "sway/workspaces" = {
              disable-scroll = true;
              format = "{name}";
            };
            "clock#1" = {
              format = "{:%a}";
              tooltip = false;
            };
            "clock#2" = {
              format = "{:%H:%M}";
              tooltip = false;
            };
            "clock#3" = {
              format = "{:%d-%m}";
              tooltip = false;
            };
            "pulseaudio" = {
              scroll-step = 1;
              format = "{icon}{volume}% {format_source}";
              format-bluetooth = "{icon}{volume}% {format_source}";
              format-muted = " {format_source}";
              format-source = "{volume}%";
              format-source-muted = "";
              format-icons = {
                headphones = "";
                hands-free = "";
                headset = "";
                phone = "";
                portable = "";
                car = "";
                default = [
                  ""
                  ""
                  ""
                ];
              };
              on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
            };
            "mpd" = {
              format = "{stateIcon} {consumeIcon}{randomIcon}{repeatIcon}{singleIcon}{artist} - {album} - {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S}) ⸨{songPosition}|{queueLength}⸩ {volume}% ";
              format-disconnected = "Disconnected ";
              format-stopped = "{consumeIcon}{randomIcon}{repeatIcon}{singleIcon}Stopped ";
              unknown-tag = "N/A";
              interval = 2;
              consume-icons = {
                on = " ";
              };
              random-icons = {
                off = "<span color=\"#${colorscheme.colors.base08}\"></span> ";
                on = " ";
              };
              repeat-icons = {
                on = " ";
              };
              single-icons = {
                on = "1 ";
              };
              state-icons = {
                paused = "";
                playing = "";
              };
              tooltip-format = "MPD (connected)";
              tooltip-format-disconnected = "MPD (disconnected)";
            };
            "network" = {
              interval = 5;
              format-wifi = "{signalStrength}%";
              format-ethernet = "";
              tooltip-format = "{ifname}: {ipaddr}/{cidr}";
              format-linked = "";
              format-disconnected = "⚠";
              format-alt = "{ifname}: {ipaddr}/{cidr}";
            };
            "backlight" = {
              format = "{percent}% {icon}";
              format-icons = ["" ""];
            };
            "sway/language" = {
              format = "{short}";
            };
            "battery" = {
              states = {
                warning = 30;
                critical = 15;
              };
              format = "{icon}{capacity}%";
              format-charging = "{capacity}%";
              format-plugged = "{capacity}%";
              format-full = "OK";
              format-icons = [
                ""
                ""
                ""
                ""
                ""
              ];
            };
            "tray" = {
              icon-size = 20;
              spacing = 5;
            };
          }
        ];
        style = let
          inherit (colorscheme) colors;
        in ''
          * {
            border: none;
            border-radius: 0;
            font-size: 16px;
            font-family: Iosevka;
            min-height: 0;
          }

          window#waybar {
            color: #${colors.base05};
            background: #${colors.base00};
          }

          #custom-right-arrow,
          #custom-left-arrow {
            color: #${colors.base02};
            background: #${colors.base00};
          }
          #custom-right-arrow-inverse,
          #custom-left-arrow-inverse {
            color: #${colors.base00};
            background: #${colors.base02};
          }

          #workspaces {
              color: #${colors.base05};
              background: #${colors.base02};
            }
          #clock.1 {
              color: #${colors.base05};
              background: #${colors.base02};
            }
          #clock.2 {
              color: #${colors.base05};
              background: #${colors.base02};
            }
          #clock.3 {
              color: #${colors.base05};
              background: #${colors.base02};
            }
          #idle_inhibitor {
              color: #${colors.base05};
              background: #${colors.base02};
            }
          #pulseaudio {
              color: #${colors.base05};
              background: #${colors.base02};
            }
          #mpd {
              color: #${colors.base05};
              background: #${colors.base02};
            }
          #network {
              color: #${colors.base05};
              background: #${colors.base02};
            }
          #backlight {
              color: #${colors.base05};
              background: #${colors.base02};
            }
          #language {
              color: #${colors.base05};
              background: #${colors.base02};
            }
          #battery {
              color: #${colors.base05};
              background: #${colors.base02};
            }
          #tray {
              color: #${colors.base05};
              background: #${colors.base02};
            }

          #workspaces button {
            padding: 0 2px;
            color: #${colors.base05};
          }
          #workspaces button.focused {
            color: #${colors.base0D};
          }
          #workspaces button:hover {
            background: #${colors.base02};
            border: #${colors.base05};
          }
        '';
      };
    };
  };
}
