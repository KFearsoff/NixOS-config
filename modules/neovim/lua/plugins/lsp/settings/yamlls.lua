local opts = {
  settings = {
    yaml = {
      schemaStore = {
        enable = false,
      },
      schemas = require('schemastore').yaml.schemas(),
    },
  },
}

return opts
