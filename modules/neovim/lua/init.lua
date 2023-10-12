local M = {}

---@param opts? LazyVimConfig
function M.setup(opts)
  require("config").setup(opts)
end

return M
