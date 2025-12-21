return {
  "nvim-lualine/lualine.nvim",
  config = function()
    local custom_theme = {
      normal = {
        a = { fg = '#000000', bg = '#7a7284' },  -- Signature teal
        b = { fg = '#c1c1c1', bg = 'NONE' },     -- Light gray
        c = { fg = '#c1c1c1', bg = 'NONE' }      -- Light gray
      },
      insert = {
        a = { fg = '#000000', bg = '#a4adb3' },  -- Muted brown
        b = { fg = '#c1c1c1', bg = 'NONE' },
        c = { fg = '#c1c1c1', bg = 'NONE' }
      },
      visual = {
        a = { fg = '#000000', bg = '#8c7f70' },  -- Darker brown
        b = { fg = '#c1c1c1', bg = 'NONE' },
        c = { fg = '#c1c1c1', bg = 'NONE' }
      },
      replace = {
        a = { fg = '#000000', bg = '#888888' },  -- Mid gray
        b = { fg = '#c1c1c1', bg = 'NONE' },
        c = { fg = '#c1c1c1', bg = 'NONE' }
      },
      command = {
        a = { fg = '#000000', bg = '#999999' },  -- Light gray        
        b = { fg = '#c1c1c1', bg = 'NONE' },
        c = { fg = '#c1c1c1', bg = 'NONE' }
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
        'fugitive',
        'quickfix',
        'nvim-dap-ui',
        'man',
        'oil',
        'mason',
      }
    })
  end
}


