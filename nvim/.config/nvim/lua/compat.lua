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

  -- Suppress vim.validate deprecation warnings from plugins using old-style calls
  -- Old style: vim.validate({ name = { val, "string" } })
  -- New style: vim.validate("name", val, "string")
  if vim.validate then
    local original_validate = vim.validate
    vim.validate = function(opt, ...)
      if type(opt) == "table" and select("#", ...) == 0 then
        -- Old-style call: vim.validate({ name = { val, type } })
        -- Convert each entry to a new-style call
        for name, spec in pairs(opt) do
          if type(spec) == "table" then
            local val = spec[1]
            local expected = spec[2]
            local optional = spec[3]
            if optional then
              if val ~= nil then
                original_validate(name, val, expected)
              end
            else
              original_validate(name, val, expected)
            end
          end
        end
        return true
      end
      return original_validate(opt, ...)
    end
  end
end

return M
