local M = {}

-- Function to get the operating system name
M.get_os = function()
  local os_name
  if vim.fn.has("win32") == 1 then
    os_name = "windows"
  elseif vim.fn.has("macunix") == 1 then
    os_name = "macos"
  else
    os_name = "linux"
  end
  return os_name
end

-- Center a window of given width in available space
M.center_in = function(available, width)
  return math.floor((available - width) / 2)
end

-- Expand a path with environment variables and '~'
M.expand_path = function(path)
  return vim.fn.expand(path)
end

return M
