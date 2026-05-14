return {
  {
    "Wansmer/treesj",
    keys = {
      -- gJ = join (multiline → single line)
      -- gS = split (single line → multiline)
      { "gJ", "<cmd>TSJJoin<cr>", desc = "Join (treesj)" },
      { "gS", "<cmd>TSJSplit<cr>", desc = "Split (treesj)" },
    },
    opts = {
      use_default_keymaps = false, -- we define our own above
      max_join_length = 150,
    },
  },
}
