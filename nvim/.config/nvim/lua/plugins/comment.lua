-- ponytail: one autocmd so .env/dotenv files get # commentstring
vim.api.nvim_create_autocmd("FileType", { pattern = "conf,cfg", callback = function() vim.bo.commentstring = "# %s" end })
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
