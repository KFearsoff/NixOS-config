local status_ok, tree = pcall(require, "nvim-tree")
if not status_ok then
  return
end

vim.opt.termguicolors = true

local function my_on_attach(bufnr)
  local api = require("nvim-tree.api")

  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  api.config.mappings.default_on_attach(bufnr)

  vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
  vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close"))
  vim.keymap.set("n", "v", api.node.open.vertical, opts("Open: Vertical Split"))
end

local function open_nvim_tree(data)
  local no_name = data.file == "" and vim.bo[data.buf].buftype == ""
  if no_name then
    return
  end
  require("nvim-tree.api").tree.toggle({ focus = false, find_file = true, })
end
vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })

vim.api.nvim_create_autocmd("QuitPre", {
  callback = function()
    local invalid_win = {}
    local wins = vim.api.nvim_list_wins()
    for _, w in ipairs(wins) do
      local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w))
      if bufname:match("NvimTree_") ~= nil then
        table.insert(invalid_win, w)
      end
    end
    if #invalid_win == #wins - 1 then
      -- Should quit, so we close all invalid windows
      for _, w in ipairs(invalid_win) do vim.api.nvim_win_close(w, true) end
    end
  end
})

tree.setup {
  on_attach = my_on_attach,

  sync_root_with_cwd = true,
  respect_buf_cwd = true,
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
