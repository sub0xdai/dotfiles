return {
  {
    "R-nvim/R.nvim",
    lazy = false,
    config = function()
      require("r").setup({})
    end,
  },
}
