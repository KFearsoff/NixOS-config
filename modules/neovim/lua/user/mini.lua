local status_ok, animate = pcall(require, "mini.animate")
if not status_ok then
  return
end

animate.setup()
