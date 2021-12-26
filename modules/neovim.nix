{ pkgs, ... }:

{
  # very much inspired by this:
  # https://github.com/LunarVim/Neovim-from-scratch/
  enable = true;
  package = pkgs.neovim-nightly;
  viAlias = true;
  vimAlias = true;
  vimdiffAlias = true;
  withNodeJs = true;

  plugins = with pkgs.vimPlugins; [
    vim-airline
    dracula-vim

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

    (nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars))
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
    -- LSP --
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

    local lspconfig = require('lspconfig')

    local servers = { 'rnix', 'bashls', 'terraformls' }
      for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup {
          -- on_attach = my_custom_on_attach,
          capabilities = capabilities,
        }
      end

    -- Mappings --
      local opts = { noremap = true, silent = true }
      local term_opts = { silent = true }
      local keymap = vim.api.nvim_set_keymap

      -- Remap space as a leader key
      keymap("", "<Space>", "<Nop>", opts)
      vim.g.mapleader = " "
      vim.g.maplocalleader = " "

      -- Normal --
      -- Better window navigation
      keymap("n", "<C-h>", "<C-w>h", opts)
      keymap("n", "<C-j>", "<C-w>j", opts)
      keymap("n", "<C-k>", "<C-w>k", opts)
      keymap("n", "<C-l>", "<C-w>l", opts)

      keymap("n", "<leader>e", ":Lex 30<cr>", opts)

      -- Resize with arrows
      keymap("n", "<C-Up>", ":resize +2<CR>", opts)
      keymap("n", "<C-Down>", ":resize -2<CR>", opts)
      keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
      keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

      -- Navigate buffers
      keymap("n", "<A-l>", ":bnext<CR>", opts)
      keymap("n", "<A-h>", ":bprevious<CR>", opts)

      -- Insert --
      -- Press jk fast to enter
      keymap("i", "jk", "<ESC>", opts)

      -- Visual --
      -- Stay in indent mode
      keymap("v", "<", "<gv", opts)
      keymap("v", ">", ">gv", opts)

      -- Move text up and down
      keymap("v", "<A-j>", ":m .+1<CR>==", opts)
      keymap("v", "<A-k>", ":m .-2<CR>==", opts)
      keymap("v", "p", '"_dP', opts) -- Pasting doesn't yank

      -- Visual Block --
      -- Move text up and down
      keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
      keymap("x", "K", ":move '<-2<CR>gv-gv", opts)
      keymap("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
      keymap("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)

      -- Terminal --
      -- Better terminal navigation
      keymap("t", "<C-h>", "<C-\\><C-N><C-w>h", term_opts)
      keymap("t", "<C-j>", "<C-\\><C-N><C-w>j", term_opts)
      keymap("t", "<C-k>", "<C-\\><C-N><C-w>k", term_opts)
      keymap("t", "<C-l>", "<C-\\><C-N><C-w>l", term_opts)

      -- keymap("n", "<leader>f", "<cmd>Telescope find_files<cr>", opts)
      keymap("n", "<leader>f", "<cmd>lua require'telescope.builtin'.find_files(require('telescope.themes').get_dropdown({ previewer = false }))<cr>", opts)
      keymap("n", "<c-t>", "<cmd>Telescope live_grep<cr>", opts)

      termguicolors = true


      -- Completions --
      local cmp_status_ok, cmp = pcall(require, "cmp")
      if not cmp_status_ok then
        return
      end

      local snip_status_ok, luasnip = pcall(require, "luasnip")
      if not snip_status_ok then
        return
      end

      local check_backspace = function()
        local col = vim.fn.col "." - 1
        return col == 0 or vim.fn.getline("."):sub(col, col):match "%s"
      end

      --   פּ ﯟ   some other good icons
      local kind_icons = {
        Text = "",
        Method = "m",
        Function = "",
        Constructor = "",
        Field = "",
        Variable = "",
        Class = "",
        Interface = "",
        Module = "",
        Property = "",
        Unit = "",
        Value = "",
        Enum = "",
        Keyword = "",
        Snippet = "",
        Color = "",
        File = "",
        Reference = "",
        Folder = "",
        EnumMember = "",
        Constant = "",
        Struct = "",
        Event = "",
        Operator = "",
        TypeParameter = "",
      }
      -- find more here: https://www.nerdfonts.com/cheat-sheet

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body) -- For `luasnip` users.
          end,
        },
        mapping = {
          ["<C-k>"] = cmp.mapping.select_prev_item(),
          ["<C-j>"] = cmp.mapping.select_next_item(),
          ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
          ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
          ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
          ["<C-y>"] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
          ["<C-e>"] = cmp.mapping {
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
          },
          -- Accept currently selected item. If none selected, `select` first item.
          -- Set `select` to `false` to only confirm explicitly selected items.
          ["<CR>"] = cmp.mapping.confirm { select = true },
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expandable() then
              luasnip.expand()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif check_backspace() then
              fallback()
            else
              fallback()
            end
          end, {
            "i",
            "s",
          }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, {
            "i",
            "s",
          }),
        },
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = function(entry, vim_item)
            -- Kind icons
            vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
            -- vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
            vim_item.menu = ({
              luasnip = "[Snippet]",
              buffer = "[Buffer]",
              path = "[Path]",
            })[entry.source.name]
            return vim_item
          end,
        },
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        },
        confirm_opts = {
          behavior = cmp.ConfirmBehavior.Replace,
          select = false,
        },
        documentation = {
          border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
        },
        experimental = {
          ghost_text = false,
          native_menu = false,
        },
      }

      -- Telescope --
      local status_ok, telescope = pcall(require, "telescope")
      if not status_ok then
        return
      end

      local actions = require "telescope.actions"

      telescope.setup {
        defaults = {

          prompt_prefix = " ",
          selection_caret = " ",
          path_display = { "smart" },

          mappings = {
            i = {
              ["<C-n>"] = actions.cycle_history_next,
              ["<C-p>"] = actions.cycle_history_prev,

              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,

              ["<C-c>"] = actions.close,

              ["<Down>"] = actions.move_selection_next,
              ["<Up>"] = actions.move_selection_previous,

              ["<CR>"] = actions.select_default,
              ["<C-x>"] = actions.select_horizontal,
              ["<C-v>"] = actions.select_vertical,
              ["<C-t>"] = actions.select_tab,

              ["<C-u>"] = actions.preview_scrolling_up,
              ["<C-d>"] = actions.preview_scrolling_down,

              ["<PageUp>"] = actions.results_scrolling_up,
              ["<PageDown>"] = actions.results_scrolling_down,

              ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
              ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
              ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["<C-l>"] = actions.complete_tag,
              ["<C-_>"] = actions.which_key, -- keys from pressing <C-/>
            },

            n = {
              ["<esc>"] = actions.close,
              ["<CR>"] = actions.select_default,
              ["<C-x>"] = actions.select_horizontal,
              ["<C-v>"] = actions.select_vertical,
              ["<C-t>"] = actions.select_tab,

              ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
              ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
              ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,

              ["j"] = actions.move_selection_next,
              ["k"] = actions.move_selection_previous,
              ["H"] = actions.move_to_top,
              ["M"] = actions.move_to_middle,
              ["L"] = actions.move_to_bottom,

              ["<Down>"] = actions.move_selection_next,
              ["<Up>"] = actions.move_selection_previous,
              ["gg"] = actions.move_to_top,
              ["G"] = actions.move_to_bottom,

              ["<C-u>"] = actions.preview_scrolling_up,
              ["<C-d>"] = actions.preview_scrolling_down,

              ["<PageUp>"] = actions.results_scrolling_up,
              ["<PageDown>"] = actions.results_scrolling_down,

              ["?"] = actions.which_key,
            },
          },
        },
        pickers = {
          -- Default configuration for builtin pickers goes here:
          -- picker_name = {
          --   picker_config_key = value,
          --   ...
          -- }
          -- Now the picker_config_key will be applied every time you call this
          -- builtin picker
        },
        extensions = {
          -- Your extension configuration goes here:
          -- extension_name = {
          --   extension_config_key = value,
          -- }
          -- please take a look at the readme of the extension you want to configure
        },
      }
  '';
}
