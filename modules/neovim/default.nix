{ pkgs, config, username, nix-colors, ... }:

let
  inherit (nix-colors.lib { inherit pkgs; }) vimThemeFromScheme;
  inherit (config.home-manager.users."${username}") colorscheme;
in
{
  config.home-manager.users."${username}".programs.neovim = {
  # very much inspired by this:
  # https://github.com/LunarVim/Neovim-from-scratch/
  enable = true;
  package = pkgs.neovim-nightly;
  viAlias = true;
  vimAlias = true;
  vimdiffAlias = true;
  withNodeJs = true;

  plugins = with pkgs.vimPlugins; [
    {
      plugin = vimThemeFromScheme { scheme = colorscheme; };
      config = "colorscheme nix-${colorscheme.slug}";
    }
    vim-airline

    # LSP
    nvim-lspconfig

    # cmp plugins
    nvim-cmp # completion plugin
    cmp-buffer # buffer completions
    cmp-path # path completions
    cmp-cmdline # cmdline completions
    cmp_luasnip # snipper completions
    cmp-nvim-lsp # LSP completions

    # snippets
    luasnip # snippet engine
    friendly-snippets # a bunch of snippets to use

    telescope-nvim
    vim-nix

    nvim-autopairs

    (nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars))
  ];

  # needed for nvim-treesitter
  extraPackages = with pkgs; [ gcc ];

    #syntax on
    #colorscheme nix-${colorscheme.slug}
    extraConfig = ''
      :lua << EOF
      ${builtins.readFile ./options.lua} 
      ${builtins.readFile ./keymaps.lua}
      ${builtins.readFile ./treesitter.lua}
      ${builtins.readFile ./autopairs.lua}
  '';
};
}
