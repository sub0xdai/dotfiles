return {
  "nvim-lualine/lualine.nvim",
  config = function()
    local custom_theme = {
      normal = {
        a = { fg = '#2D2D2D', bg = '#B4BEFE' },  -- Soft lavender
        b = { fg = '#f8f8f2', bg = 'NONE' },
        c = { fg = '#f8f8f2', bg = 'NONE' }
      },
      insert = {
        a = { fg = '#2D2D2D', bg = '#98C379' },  -- Soft sage green
        b = { fg = '#f8f8f2', bg = 'NONE' },
        c = { fg = '#f8f8f2', bg = 'NONE' }

      },
      visual = {
        a = { fg = '#2D2D2D', bg = '#FAB387' },  -- Soft peach
        b = { fg = '#f8f8f2', bg = 'NONE' },
        c = { fg = '#f8f8f2', bg = 'NONE' }
      },
      replace = {
        a = { fg = '#2D2D2D', bg = '#F5C2C2' },  -- Soft pink
        b = { fg = '#f8f8f2', bg = 'NONE' },
        c = { fg = '#f8f8f2', bg = 'NONE' }
      },
      command = {
        a = { fg = '#2D2D2D', bg = '#ebbcba' },  -- Soft rose        
        b = { fg = '#f8f8f2', bg = 'NONE' },
        c = { fg = '#f8f8f2', bg = 'NONE' }
      }
    }

    require('lualine').setup({
      options = {
        icons_enabled = true,
        theme = custom_theme,
        component_separators = { left = '', right = ''},
        section_separators = { left = '', right = ''},
        globalstatus = true
      },
      extensions = {
        'neo-tree',
        'fugitive',
        'quickfix',
        'nvim-dap-ui',
        'man',
        'oil',
        'mason',
        'fzf'
      }
    })
  end
}


