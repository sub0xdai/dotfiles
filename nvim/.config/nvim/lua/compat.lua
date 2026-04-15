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
  -- Old style: vim.validate({ name = { val, "string" } }) with shorthand types ("s", "f", etc.)
  -- New style: vim.validate("name", val, "string") with full type names
  if vim.validate then
    local original_validate = vim.validate
    -- Old API accepted shorthand type names; new API requires full names
    local type_aliases = {
      s = "string", t = "table", n = "number",
      f = "function", b = "boolean", c = "callable",
    }
    vim.validate = function(opt, ...)
      if type(opt) == "table" and select("#", ...) == 0 then
        for name, spec in pairs(opt) do
          if type(spec) == "table" then
            local val = spec[1]
            local expected = type_aliases[spec[2]] or spec[2]
            local optional = spec[3]
            if not optional or val ~= nil then
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
