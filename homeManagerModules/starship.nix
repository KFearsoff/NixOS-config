{
  config,
  lib,
  ...
}: let
  cfg = config.nixchad.starship;
  inherit (config) colorScheme;
  inherit (lib) mkEnableOption mkIf;
in {
  options.nixchad.starship = {
    enable = mkEnableOption "starship" // {default = true;};
  };

  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
      settings = {
        add_newline = false;
        directory = {
          truncation_length = 1;
          fish_style_pwd_dir_length = 1;
          style = "bold #${colorScheme.palette.base0B}";
        };
        cmd_duration.style = "bold #${colorScheme.palette.base0A}";
        hostname.style = "bold #${colorScheme.palette.base08}";
        git_branch.style = "bold #${colorScheme.palette.base0E}";
        git_status.style = "bold #${colorScheme.palette.base08}";
        username.style_user = "bold #${colorScheme.palette.base09}";
        character = {
          success_symbol = "[❯](bold #${colorScheme.palette.base05})";
          error_symbol = "[❯](bold #${colorScheme.palette.base08})";
          vicmd_symbol = "[❮](bold #${colorScheme.palette.base05})";
        };

        line_break.disabled = true;
        nix_shell.disabled = true; # useless, only works for direnv shells
      };
    };
  };
}
