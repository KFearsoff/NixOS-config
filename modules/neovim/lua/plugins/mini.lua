local status_ok, animate = pcall(require, "mini.animate")
if not status_ok then
  return
end
animate.setup()

local status_ok, bufremove = pcall(require, "mini.bufremove")
if not status_ok then
  return
end
bufremove.setup()

setKeymap("<leader>bd", "<cmd>lua require'mini.bufremove'.delete(0, false)<cr>", "Delete Buffer")
setKeymap("<leader>bD", "<cmd>lua require'mini.bufremove'.delete(0, true)<cr>", "Delete Buffer (Force)")

local status_ok, pairs = pcall(require, "mini.pairs")
if not status_ok then
  return
end
pairs.setup()

local status_ok, comment = pcall(require, "mini.comment")
if not status_ok then
  return
end
comment.setup()
