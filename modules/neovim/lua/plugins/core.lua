require("config").init()

return {
  { "folke/lazy.nvim",         dev = true, version = "*" },
  { name = "config-as-plugin", dir = "..", main = "config", priority = 10000, lazy = false, config = true, cond = true },
}
