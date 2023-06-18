local status_ok, bufferline = pcall(require, "bufferline")
if not status_ok then
  return
end

bufferline.setup {
  options = {
    enforce_regular_tabs = true,
    diagnostics = "nvim_lsp",
    offsets = {
      {
        filetype = "NvimTree",
        text = "",
        highlight = "Directory",
        separator = true     -- use a "true" to enable the default, or set your own character
      }
    },
  },
}
