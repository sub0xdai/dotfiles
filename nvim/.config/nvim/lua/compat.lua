-- Create a file called compat.lua in your lua directory

-- Compatibility layer for deprecated Neovim functions
local M = {}

function M.setup()
  -- Check if we're on Neovim 0.12+ where vim.tbl_islist is deprecated
  if vim.fn.has('nvim-0.12') == 1 then
    -- Provide a fallback for vim.tbl_islist
    if not vim.tbl_islist and vim.islist then
      vim.tbl_islist = function(t)
        return vim.islist(t)
      end
    end
  end

  -- Create a compatibility layer for vim.validate which is deprecated and will be removed in Neovim 1.0
  if vim.validate then
    local original_validate = vim.validate
    vim.validate = function(...)
      -- Check if we should silence the deprecation warning
      local args = {...}
      original_validate(...)
      return true
    end
  end
end

return M
