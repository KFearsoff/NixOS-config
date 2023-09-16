return {
  {
    "ahmedkhalf/project.nvim",
    dev = true,
    opts = {},
    event = "VeryLazy",
    config = function(_, opts)
      require("project_nvim").setup(opts)
      require("telescope").load_extension("projects")
    end,
    keys = {
      { "<leader>fp", "<Cmd>Telescope projects<CR>", desc = "Projects" },
    },
  },

  -- FIXME: dunno why that doesn't work
  -- {
  --   "goolord/alpha-nvim",
  --   dev = true,
  --   optional = true,
  --   opts = function(_, dashboard)
  --     local button = dashboard.button("p", " " .. " Projects", ":Telescope projects <CR>")
  --     button.opts.hl = "AlphaButtons"
  --     button.opts.hl_shortcut = "AlphaShortcut"
  --     table.insert(dashboard.section.buttons.val, 4, button)
  --   end,
  -- },

  {
    "echasnovski/mini.starter",
    dev = true,
    optional = true,
    opts = function(_, opts)
      local items = {
        {
          name = "Projects",
          action = "Telescope projects",
          section = string.rep(" ", 22) .. "Telescope",
        },
      }
      vim.list_extend(opts.items, items)
    end,
  },
}
