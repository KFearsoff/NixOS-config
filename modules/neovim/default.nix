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
    #vim-nix
    indentLine

    nvim-autopairs

    (nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars))
  ];

  extraPackages = with pkgs; 
  [
    gcc # needed for nvim-treesitter
    rnix-lsp
    terraform-ls
    nodePackages.bash-language-server
    sumneko-lua-language-server
  ];

    extraConfig = ''
      :lua << EOF
      ${builtins.readFile ./options.lua} 
      ${builtins.readFile ./keymaps.lua}
      ${builtins.readFile ./cmp.lua}
      ${builtins.readFile ./lsp/lsp.lua}
      ${builtins.readFile ./treesitter.lua}
      ${builtins.readFile ./autopairs.lua}
  '';
};
}
