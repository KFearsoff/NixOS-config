{
  config,
  lib,
  ...
}:
let
  cfg = config.nixchad.starship;
  inherit (config.lib.stylix.colors)
    base05
    base08
    base09
    base0A
    base0B
    base0E
    ;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.nixchad.starship = {
    enable = mkEnableOption "starship" // {
      default = config.nixchad.full.enable;
    };
  };

  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
      settings = {
        add_newline = false;
        directory = {
          truncation_length = 1;
          fish_style_pwd_dir_length = 1;
          style = "bold #${base0B}";
        };
        cmd_duration.style = "bold #${base0A}";
        hostname.style = "bold #${base08}";
        git_branch.style = "bold #${base0E}";
        git_status.style = "bold #${base08}";
        username.style_user = "bold #${base09}";
        character = {
          success_symbol = "[❯](bold #${base05})";
          error_symbol = "[❯](bold #${base08})";
          vicmd_symbol = "[❮](bold #${base05})";
        };

        line_break.disabled = true;
        nix_shell.disabled = true; # useless, only works for direnv shells
      };
    };
  };
}
