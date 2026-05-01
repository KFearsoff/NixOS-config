return {
  {
    "chipsenkbeil/org-roam.nvim",
    tag = "0.2.0",
    dependencies = {
      {
        "nvim-orgmode/orgmode",
        tag = "0.7.0",
      },
    },
    config = function()
      require("org-roam").setup({
        directory = "~/Documents/Projects/algernon-orgroam",
      })
    end,
  },
}
