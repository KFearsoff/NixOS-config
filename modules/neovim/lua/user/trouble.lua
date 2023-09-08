local status_ok, trouble = pcall(require, "trouble")
if not status_ok then
  return
end

trouble.setup{
  use_diagnostic_signs = true,
}

setKeymap("<leader>xx", "<cmd>TroubleToggle document_diagnostics<cr>", "Document Diagnostics (Trouble)")
-- vim.keymap.set("n", "<leader>xx", function() require("trouble").open() end, {noremap = true, silent = true, desc = "Document Diagnostics (Trouble)"})
setKeymap("<leader>xX", "<cmd>TroubleToggle workspace_diagnostics<cr>", "Workspace Diagnostics (Trouble)")
setKeymap("<leader>xL", "<cmd>TroubleToggle loclist<cr>", "Location List (Trouble)")
setKeymap("<leader>xQ", "<cmd>TroubleToggle quickfix<cr>", "Quickfix List (Trouble)")
setKeymap("[q", [[<cmd>lua function()
  if require("trouble").is_open then
    require("trouble").previous({skip_groups = true, jump = true})
  else
    local ok, err = pcall(vim.cmd.cprev)
    if not ok then
      vim.notify(err, vim.log.levels.ERROR)
    end
  end
end]], "Previous trouble/quickfix item")
