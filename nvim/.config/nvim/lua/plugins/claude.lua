return {
  "greggh/claude-code.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },

  keys = {
    -- Your keymap for Normal Mode
    {
      "<leader>ac",
      "<cmd>ClaudeCode<CR>",
      desc = "Claude Code (Toggle)",
    },
    -- A NEW, dedicated keymap just for Terminal Mode
    {
      "<A-c>", -- Alt+c
      "<cmd>ClaudeCode<CR>",
      mode = "t", -- This 't' is important, it means Terminal Mode only
      desc = "Claude Code (Toggle from Terminal)",
    },
    {
      "<leader>aC",
      "<cmd>ClaudeCodeContinue<CR>",
      desc = "Claude Code (Continue)",
    },
  },

  config = function()
    require("claude-code").setup({
      -- Your other settings...
    })
  end,
}
