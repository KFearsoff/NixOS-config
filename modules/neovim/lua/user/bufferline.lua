local status_ok, bufferline = pcall(require, "bufferline")
if not status_ok then
  return
end

bufferline.setup {
  options = {
    close_command = function(n) require("mini.bufremove").delete(n, false) end,
    right_mouse_command = function(n) require("mini.bufremove").delete(n, false) end,
    diagnostics = "nvim_lsp",
    always_show_bufferline = false,
    offsets = {
      {
        filetype = "neo-tree",
        text = "Neo-Tree",
        highlight = "Directory",
        text_align = "left",
      }
    },
  },
}

local Offset = require("bufferline.offset")
Offset.get = function ()
  if not Offset.edgy then
    local get = Offset.get
    if package.loaded.edgy then
      local layout = require("edgy.config").layout
      local ret = { left = "", left_size = 0, right = "", right_size = 0 }
      for _, pos in ipairs({"left", "right"}) do
        local sb = layout[pos]
        if sb and #sb.wins > 0 then
          local title = " Sidebar" .. string.rep(" ", sb.bounds.width - 8)
          ret[pos] = "%#EdgyTitle#" .. title .. "%*" .. "%#WinSeparator#|%*"
          ret[pos .. "_size" ] = sb.bounds.width
        end
      end
      ret.total_size = ret.left_size + ret.right_size
      if ret.total_size > 0 then
        return ret
      end
    return get()
    end
    Offset.edgy = true
  end
end
