return {
  -- add json to treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    dev = true,
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "json" })
      end
    end,
  },

  -- correctly setup lspconfig
  {
    "neovim/nvim-lspconfig",
    dev = true,
    dependencies = {
      "b0o/SchemaStore.nvim",
      dev = true,
      version = false, -- last release is way too old
    },
    opts = {
      -- make sure mason installs the server
      servers = {
        jsonls = {
          -- lazy-load schemastore when needed
          on_new_config = function(new_config)
            new_config.settings.json.schemas = new_config.settings.json.schemas or {}
            vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
          end,
          settings = {
            json = {
              format = {
                enable = true,
              },
              validate = { enable = true },
            },
            cmd = { "vscode-json-languageserver", "--stdio" }, -- bin name is different
          },
        },
      },
    },
  },
}