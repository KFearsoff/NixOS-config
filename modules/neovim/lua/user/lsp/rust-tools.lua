local status_ok, rt = pcall(require, "rust-tools")
if not status_ok then
  return
end

local opts = {}

rt.setup({
  server = {
    on_attach = require("user.lsp.handlers").on_attach,
    capabilities = require("user.lsp.handlers").capabilities,
  },
})
