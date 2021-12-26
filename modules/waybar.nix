{ colorscheme, ... }:

{
  # inspired by:
  # https://github.com/cjbassi/config/tree/master/.config/waybar
  enable = true;
  settings = [{
    layer = "top";
    position = "top";
    height = 30;
    modules-left = [
      "sway/workspaces"
      "sway/mode"
      "custom/right-arrow-dark"
    ];
    modules-center = [
      "custom/left-arrow-dark"
      "clock#1"
      "custom/left-arrow-light"
      "custom/left-arrow-dark"
      "clock#2"
      "custom/right-arrow-dark"
      "custom/right-arrow-light"
      "clock#3"
      "custom/right-arrow-dark"
    ];
    modules-right = [
      "custom/left-arrow-dark"
      "idle_inhibitor"
      "custom/left-arrow-light"
      "custom/left-arrow-dark"
      "pulseaudio"
      "custom/left-arrow-light"
      "custom/left-arrow-dark"
      "mpd"
      "custom/left-arrow-light"
      "custom/left-arrow-dark"
      "network"
      "custom/left-arrow-light"
      "custom/left-arrow-dark"
      "backlight"
      "custom/left-arrow-light"
      "custom/left-arrow-dark"
      "language"
      "custom/left-arrow-light"
      "custom/left-arrow-dark"
      "battery"
      "custom/left-arrow-light"
      "custom/left-arrow-dark"
      "tray"
    ];

    modules = {
      "custom/left-arrow-dark" = {
        format = "";
        tooltip = false;
      };
      "custom/left-arrow-light" = {
        format = "";
        tooltip = false;
      };
      "custom/right-arrow-dark" = {
        format = "";
        tooltip = false;
      };
      "custom/right-arrow-light" = {
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
        format = "{:%m-%d}";
        tooltip = false;
      };
      "pulseaudio" = {
        format = "{icon}  {volume:2}%";
        format-bluetooth = "{icon}  {volume}%";
        format-muted = "MUTE";
        format-icons = {
          headphones = "";
          default = [
            ""
            ""
          ];
        };
        scroll-step = 5;
        on-click = "pavucontrol";
      };
      "battery" = {
        states = {
          good = 95;
          warning = 30;
          critical = 15;
        };
        format = "{icon}  {capacity}%";
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
      };
      "network" = {
        interval = 5;
        format-wifi = "  {signalStrength}%";
        format-ethernet = "";
        format-disconnected = "⚠";
      };
      "language" = {
        format = "{shortDescription}";
      };
    };
  }];
  style = let colors = colorscheme.colors; in
    ''
      * {
        font-size: 20;
        font-family: Iosevka;
      }
    
      window#waybar {
        color: #${colors.base05};
        background: #${colors.base00};
        border-bottom: 2px solid #${colors.base0C};
      }
    
      #custom-right-arrow-dark,
      #custom-left-arrow-dark {
        color: #${colors.base05};
      }
      #custom-right-arrow-light,
      #custom-left-arrow-light {
        color: #${colors.base00};
        background: #${colors.base05};
      }
    
      #workspaces,
      #clock.1,
      #clock.2,
      #clock.3,
      #pulseaudio,
      #memory,
      #cpu,
      #battery,
      #disk,
      #tray {
        background: #1a1a1a;
      }
    
      #workspaces button {
        padding: 0 2px;
        color: #fdf6e3;
      }
      #workspaces button.focused {
        color: #268bd2;
      }
      #workspaces button:hover {
        box-shadow: inherit;
        text-shadow: inherit;
      }
      #workspaces button:hover {
        background: #1a1a1a;
        border: #1a1a1a;
        padding: 0 3px;
      }
    
      #pulseaudio {
        color: #268bd2;
      }
      #memory {
        color: #2aa198;
      }
      #cpu {
        color: #6c71c4;
      }
      #battery {
        color: #859900;
      }
      #disk {
        color: #b58900;
      }
    
      #clock,
      #pulseaudio,
      #memory,
      #cpu,
      #battery,
      #disk {
        padding: 0 10px;
      }
    '';
}
