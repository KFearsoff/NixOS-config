local status_ok, edgy = pcall(require, "edgy")
if not status_ok then
  return
end

-- views can only be fully collapsed with the global statusline
vim.opt.laststatus = 3
-- Default splitting will cause your main splits to jump when opening an edgebar.
-- To prevent this, set `splitkeep` to either `screen` or `topline`.
vim.opt.splitkeep = "screen"

edgy.setup {
  left = {
    {
      ft = "nvim-tree",
      size = { width = 0.3 },
      pinned = true,
      open = "NvimTreeOpen",
    },
    {
      ft = "toggleterm",
      size = { width = 0.15 },
      -- exclude floating windows
      filter = function(buf, win)
        return vim.api.nvim_win_get_config(win).relative == ""
      end,
      pinned = true,
      open = "ToggleTerm",
    },
  },
  bottom = {
    {
      ft = "toggleterm",
      size = { height = 0.15 },
      -- exclude floating windows
      filter = function(buf, win)
        return vim.api.nvim_win_get_config(win).relative == ""
      end,
      pinned = true,
      open = "ToggleTerm",
    },
    {
      ft = "Trouble",
      pinned = true,
      open = "Trouble",
    },
  },
  right = {},
  top = {},

  options = {
    left = { size = 30 },
    bottom = { size = 10 },
    right = { size = 30 },
    top = { size = 10 },
  },
  -- edgebar animations
  animate = {
    enabled = false,
    fps = 100, -- frames per second
    cps = 120, -- cells per second
    on_begin = function()
      vim.g.minianimate_disable = true
    end,
    on_end = function()
      vim.g.minianimate_disable = false
    end,
    -- Spinner for pinned views that are loading.
    -- if you have noice.nvim installed, you can use any spinner from it, like:
    -- spinner = require("noice.util.spinners").spinners.circleFull,
    spinner = {
      frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
      interval = 80,
    },
  },
  -- enable this to exit Neovim when only edgy windows are left
  exit_when_last = true,
  -- close edgy when all windows are hidden instead of opening one of them
  -- disable to always keep at least one edgy split visible in each open section
  close_when_all_hidden = false,
  -- global window options for edgebar windows
  wo = {
    -- Setting to `true`, will add an edgy winbar.
    -- Setting to `false`, won't set any winbar.
    -- Setting to a string, will set the winbar to that string.
    winbar = false,
    winfixwidth = true,
    winfixheight = false,
    winhighlight = "WinBar:EdgyWinBar,Normal:EdgyNormal",
    spell = false,
    signcolumn = "no",
  },
  -- buffer-local keymaps to be added to edgebar buffers.
  -- Existing buffer-local keymaps will never be overridden.
  -- Set to false to disable a builtin.
  keys = {
    -- close window
    ["q"] = function(win)
      win:close()
    end,
    -- hide window
    ["<c-q>"] = function(win)
      win:hide()
    end,
    -- close sidebar
    ["Q"] = function(win)
      win.view.edgebar:close()
    end,
    -- next open window
    ["]w"] = function(win)
      win:next({ visible = true, focus = true })
    end,
    -- previous open window
    ["[w"] = function(win)
      win:prev({ visible = true, focus = true })
    end,
    -- next loaded window
    ["]W"] = function(win)
      win:next({ pinned = false, focus = true })
    end,
    -- prev loaded window
    ["[W"] = function(win)
      win:prev({ pinned = false, focus = true })
    end,
    -- increase width
    ["<c-w>>"] = function(win)
      win:resize("width", 2)
    end,
    -- decrease width
    ["<c-w><lt>"] = function(win)
      win:resize("width", -2)
    end,
    -- increase height
    ["<c-w>+"] = function(win)
      win:resize("height", 2)
    end,
    -- decrease height
    ["<c-w>-"] = function(win)
      win:resize("height", -2)
    end,
    -- reset all custom sizing
    ["<c-w>="] = function(win)
      win.view.edgebar:equalize()
    end,
  },
  icons = {
    closed = " ",
    open = " ",
  },
  -- enable this on Neovim <= 0.10.0 to properly fold edgebar windows.
  -- Not needed on a nightly build >= June 5, 2023.
  -- fix_win_height = vim.fn.has("nvim-0.10.0") == 0,
}
