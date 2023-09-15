local status_ok, notify = pcall(require, "notify")
if not status_ok then
  return
end

notify.setup({
  timeout = 3000,
  max_height = function()
    return math.floor(vim.o.lines * 0.75)
  end,
  max_width = function()
    return math.floor(vim.o.columns * 0.75)
  end,
})
