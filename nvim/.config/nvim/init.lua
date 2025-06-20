local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.python3_host_prog = vim.fn.exepath('python3')
vim.wo.relativenumber = true

-- VimTeX configuration (must be set before plugins load)
vim.g.maplocalleader = " "
vim.g.vimtex_view_method = "zathura"
vim.g.vimtex_compiler_method = "tectonic"
vim.g.vimtex_quickfix_mode = 0

vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    command = "setlocal conceallevel=2"
})

-- Add compatibility layer for deprecated Vim functions
-- This helps older plugins work with newer Neovim versions
if vim.fn.has('nvim-0.12') == 1 then
  -- Only add the compatibility function if the new function exists
  -- and the old one doesn't
  if vim.islist and not vim.tbl_islist then
    vim.tbl_islist = vim.islist
  end
end

require("compat").setup()
require("vim-options")
require("lazy").setup("plugins")
