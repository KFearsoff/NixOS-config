{ pkgs, ... }:

{
  enable = true;
  package = pkgs.neovim-nightly;
  viAlias = true;
  vimAlias = true;
  vimdiffAlias = true;

  plugins = with pkgs.vimPlugins; [
  vim-airline
  #vim-nix
  dracula-vim

    nvim-lspconfig 
    nvim-cmp
    cmp-nvim-lsp

    (nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars))

    cmp_luasnip
    luasnip
    completion-nvim
    vim-snippets
    vim-closer
    vim-commentary
  ];

  # needed for nvim-treesitter
  extraPackages = with pkgs; [ gcc ];

  extraConfig = ''
    set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz
    set clipboard=unnamedplus
    syntax on
    colorscheme dracula
    au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
    set nocompatible
    set showmatch
    set ignorecase
    set mouse=v
    set hlsearch
    set incsearch
    set tabstop=2
    set softtabstop=2
    set expandtab
    set shiftwidth=2
    set autoindent
    set number
    set relativenumber
    set wildmode=longest,list
    set cc=80
    filetype plugin indent on
    set mouse=a
    filetype plugin on
    set cursorline
    set scrolloff=7

          set completeopt=menu,menuone,noselect,noinsert
          let g:completion_matching_strategy_list = ['exact', 'substring', 'fuzzy']
    :lua << EOF
      local configs = require'nvim-treesitter.configs'
      configs.setup {
        ensure_installed = "maintained",
        highlight = {
          enable = true,
        },
        indent = {
          enable = true,
        }
      }
      -- vim.opt.foldmethod = "expr"
      -- vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
      -- require'lspconfig'.rnix.setup{}

      -- Add additional capabilities supported by nvim-cmp
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
      
      
      local lspconfig = require('lspconfig')
      
      -- Enable some language servers with the additional completion capabilities offered by nvim-cmp
      local servers = { 'rnix' }
      for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup {
          -- on_attach = my_custom_on_attach,
          capabilities = capabilities,
        }
      end
      
      -- Set completeopt to have a better completion experience
      vim.o.completeopt = 'menuone,noselect'
      
      -- luasnip setup
      local luasnip = require 'luasnip'
      
      -- nvim-cmp setup
      local cmp = require 'cmp'
      cmp.setup {
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        mapping = {
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.close(),
          ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          },
          ['<Tab>'] = function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end,
          ['<S-Tab>'] = function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end,
        },
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        },
      }
      '';
}
