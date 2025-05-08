return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
  end,
  opts = {
    -- Window appearance settings
    win = {
      border = "single", -- none, single, double, shadow
      padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
      title = true,
      title_pos = "center",
      wo = {
        winblend = 0,
      },
    },
    
    -- Layout settings
    layout = {
      height = { min = 4, max = 25 }, -- min and max height of the columns
      width = { min = 20, max = 50 }, -- min and max width of the columns
      spacing = 3, -- spacing between columns
      align = "left", -- align columns left, center or right
    },
    
    -- Icons configuration
    icons = {
      breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
      separator = "➜", -- symbol used between a key and it's label
      group = "+", -- symbol prepended to a group
      mappings = true, -- set to false to disable all mapping icons
      rules = false, -- disable default icon rules
    },
  },
  keys = {
    -- Added useful keymap to show buffer-local keymaps
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
}
