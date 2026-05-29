return {
  {
    "numToStr/Comment.nvim",
    lazy = false,
    config = function()
      require("Comment").setup({
        padding = true,
        sticky = true,
        ignore = "^$",
        toggler = {
          line = "gcc",
          block = "gbc",
        },
      })
    end,
  },
}
