local opts = { noremap = true, silent = true }

local term_opts = { silent = true }

function setKeymap(lhs, rhs, desc, mode)
  if mode == nil then
    mode = "n"
  end
  opts = opts
  opts.desc = desc

  vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
end

function setTermKeymap(lhs, rhs, desc, mode)
  if mode == nil then
    mode = "n"
  end
  opts = term_opts
  opts.desc = desc

  vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
end
