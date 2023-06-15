local opts = {
  settings = {
    json = {
      schemas = require('schemastore').json.schemas(),
      validate = { enable = true },
    },
  },
  cmd = { "vscode-json-languageserver", "--stdio" }, -- bin name is different
}

return opts
