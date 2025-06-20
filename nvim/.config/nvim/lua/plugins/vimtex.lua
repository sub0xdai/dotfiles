return
  {
  "lervag/vimtex",
  lazy = false,
  init = function()
    vim.g.maplocalleader = " "
    vim.g.vimtex_view_method = "zathura"
    -- That's it! Everything else uses defaults
  end,
}

