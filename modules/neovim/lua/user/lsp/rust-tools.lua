local status_ok, rt = pcall(require, "rust-tools")
if not status_ok then
  return
end

local opts = {
  server = {
    on_attach = require("user.lsp.handlers").on_attach,
    capabilities = require("user.lsp.handlers").capabilities,
    settings = {
      ["rust-analyzer"] = {
        procMacro = {
          enable = true,
          attributes = {
            enable = true,
          }
        },
        cachePriming = {
          enable = true, -- https://github.com/rust-lang/rust-analyzer/issues/14495#issuecomment-1498571185
        },
        lru = {
          capacity = 256, -- https://github.com/rust-lang/rust-analyzer/issues/13916#issuecomment-1396705571
        },
      },
    }
  },
}

rt.setup(opts)
