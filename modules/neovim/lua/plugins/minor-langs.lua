return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        ["*"] = { "editorconfig-checker" },
      },
    }
  },
}
