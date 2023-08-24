local status_ok, indent = pcall(require, "guess-indent")
if not status_ok then
  return
end

indent.setup()
