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
vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    command = "setlocal conceallevel=2"

})



require("vim-options")
require("lazy").setup("plugins")


