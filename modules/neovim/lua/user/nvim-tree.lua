local status_ok, tree = pcall(require, "nvim-tree")
if not status_ok then
  return
end

vim.opt.termguicolors = true

local function my_on_attach(bufnr)
  local api = require("nvim-tree.api")

  local function opts(desc)
    return {desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  api.config.mappings.default_on_attach(bufnr)

  vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
  vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close"))
  vim.keymap.set("n", "v", api.node.open.vertical, opts("Open: Vertical Split"))
end

tree.setup {
  on_attach = my_on_attach,

  sync_root_with_cwd = true,
  diagnostics = {
    enable = true,
  },
  update_focused_file = {
    enable = true,
    update_root = true,
  },
  renderer = {
    highlight_git = true,
  },
}
