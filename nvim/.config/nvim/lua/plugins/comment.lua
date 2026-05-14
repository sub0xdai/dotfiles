return {
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    opts = {
      -- treesitter-aware commenting; gc/gb work across all languages
      padding = true,
      sticky = true,
      ignore = "^$",
      toggler = {
        line = "gcc",
        block = "gbc",
      },
    },
  },
}
