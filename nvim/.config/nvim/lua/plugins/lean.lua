return {
  'Julian/lean.nvim',
  event = { 'BufReadPre *.lean', 'BufNewFile *.lean' },

  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
  },

  ---@type lean.Config
  opts = {
    -- Enable default keybindings
    mappings = true,

    -- LSP configuration
    lsp = {
      init_options = {
        -- Optimized edit delay: 10ms balances responsiveness with CPU usage
        editDelay = 10,

        -- Enable interactive widgets in infoview
        hasWidgets = true,
      }
    },

    -- Infoview configuration
    infoview = {
      -- Smart autoopen: only for small files (active proving), manual for large files (reading)
      autoopen = function()
        local line_count = vim.api.nvim_buf_line_count(0)
        return line_count <= 100
      end,

      -- Window dimensions
      width = 50,
      height = 20,

      -- Dynamic orientation based on screen layout
      orientation = "auto",

      -- Position when horizontal
      horizontal_position = "bottom",

      -- Show pin indicators intelligently
      indicators = "auto",
    },

    -- Unicode abbreviation support (essential for Lean notation)
    abbreviations = {
      enable = true,
      leader = '\\', -- type \alpha for α, \to for →, etc.
    },

    -- Progress bars for elaboration status
    progress_bars = {
      enable = true,
      character = '│',
    },

    -- Error message handling
    stderr = {
      enable = true,
      height = 5,
    },

    -- File protection
    ft = {
      -- Protect standard library and dependency files from accidental edits
      nomodifiable = {
        -- Default patterns protect stdlib and _target/* - keeps defaults
      }
    },
  }
}
