{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.nixchad.starship;
  inherit (config.hm) colorscheme;
in {
  options.nixchad.starship = {
    enable = mkEnableOption "starship";
  };

  config = mkIf cfg.enable {
    hm = {
      programs.starship = {
        enable = true;
        settings = {
          add_newline = false;
          directory = {
            truncation_length = 1;
            fish_style_pwd_dir_length = 1;
            style = "bold #${colorscheme.colors.base0B}";
          };
          cmd_duration.style = "bold #${colorscheme.colors.base0A}";
          hostname.style = "bold #${colorscheme.colors.base08}";
          git_branch.style = "bold #${colorscheme.colors.base0E}";
          git_status.style = "bold #${colorscheme.colors.base08}";
          username.style_user = "bold #${colorscheme.colors.base09}";
          character = {
            success_symbol = "[❯](bold #${colorscheme.colors.base05})";
            error_symbol = "[❯](bold #${colorscheme.colors.base08})";
            vicmd_symbol = "[❮](bold #${colorscheme.colors.base05})";
          };

          line_break.disabled = true;
          nix_shell.disabled = true; # useless, only works for direnv shells

          aws.format = "via [$symbol]($style)";
          azure.format = "via [$symbol]($style)";
          buf.format = "via [$symbol]($style)";
          cmake.format = "via [$symbol]($style)";
          cobol.format = "via [$symbol]($style)";
          crystal.format = "via [$symbol]($style)";
          dart.format = "via [$symbol]($style)";
          deno.format = "via [$symbol]($style)";
          docker_context.format = "via [$symbol]($style)";
          dotnet.format = "via [$symbol]($style)";
          elixir.format = "via [$symbol]($style)";
          elm.format = "via [$symbol]($style)";
          erlang.format = "via [$symbol]($style)";
          gcloud.format = "via [$symbol]($style)";
          golang.format = "via [$symbol]($style)";
          haskell.format = "via [$symbol]($style)";
          helm.format = "via [$symbol]($style)";
          julia.format = "via [$symbol]($style)";
          kotlin.format = "via [$symbol]($style)";
          lua.format = "via [$symbol]($style)";
          nim.format = "via [$symbol]($style)";
          nodejs.format = "via [$symbol]($style)";
          ocaml.format = "via [$symbol]($style)";
          perl.format = "via [$symbol]($style)";
          php.format = "via [$symbol]($style)";
          pulumi.format = "via [$symbol]($style)";
          purescript.format = "via [$symbol]($style)";
          python.format = "via [$symbol]($style)";
          red.format = "via [$symbol]($style)";
          rlang.format = "via [$symbol]($style)";
          ruby.format = "via [$symbol]($style)";
          rust.format = "via [$symbol]($style)";
          swift.format = "via [$symbol]($style)";
          terraform.format = "via [$symbol]($style) ";
          vagrant.format = "via [$symbol]($style)";
          vlang.format = "via [$symbol]($style)";
          zig.format = "via [$symbol]($style)";
        };
      };
    };
  };
}
