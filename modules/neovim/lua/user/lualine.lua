local status_ok, lualine = pcall(require, "lualine")
if not status_ok then
  return
end

lualine.setup({
  options = {
    component_separators = { left = "", right = "" },
    section_separators = { left = "", right = "" },
    disabled_filetypes = { "alpha", "NvimTree", "Outline" },
  },
  -- sections = {
  -- lualine_a = { branch, diagnostics },
  -- lualine_b = { mode },
  -- lualine_c = {},
  -- -- lualine_x = { "encoding", "fileformat", "filetype" },
  -- lualine_x = { diff, spaces, "encoding", filetype },
  -- lualine_y = { location },
  -- lualine_z = { progress },
  -- },
})
