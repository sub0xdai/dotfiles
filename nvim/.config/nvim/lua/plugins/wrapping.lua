return {
  "andrewferrier/wrapping.nvim",
  event = "BufEnter",
  config = function(_, opts)
    local wrapping = require("wrapping")
    wrapping.setup(opts)
    wrapping.set_mode_heuristically()
  end,
  opts = {
    softener = {
      markdown = true,
      latex = true,
      text = true,
    },
    create_keymaps = false,
  },
  keys = {
    { "<leader>ww", function() require("wrapping").toggle_wrap_mode() end, desc = "Toggle wrap mode" },
    { "<leader>ws", function() require("wrapping").soft_wrap_mode() end, desc = "Soft wrap mode" },
    { "<leader>wh", function() require("wrapping").hard_wrap_mode() end, desc = "Hard wrap mode" },
  },
}
