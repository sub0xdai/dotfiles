vim = vim or {}

-- General Settings
vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.g.mapleader = " "
vim.g.maplocalleader = ' '
vim.g.background = "light"

vim.opt.swapfile = false
vim.opt.clipboard = 'unnamedplus'   -- use system clipboard
vim.opt.splitbelow = true           -- open new vertical split bottom
vim.opt.splitright = true           -- open new horizontal splits right
vim.opt.splitkeep = "cursor"
vim.wo.number = true

-- Key Mappings
vim.keymap.set('n', '<c-k>', ':wincmd k<CR>')
vim.keymap.set('n', '<c-j>', ':wincmd j<CR>')
vim.keymap.set('n', '<c-h>', ':wincmd h<CR>')
vim.keymap.set('n', '<c-l>', ':wincmd l<CR>')
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>h', ':nohlsearch<CR>')
vim.keymap.set('n', '<C-n>', ':vnew<CR>', {noremap = true, silent = true})
vim.keymap.set('n', '<leader>cx', ':chmod +x %<CR>', opts)


-- Copy Full Path of Current File
vim.keymap.set('n', '<Leader>cpf', ':let @+ = expand("%:p")<CR>', { noremap = true, silent = true, desc = "Copy full path of current file" })

-- Make File Executable
vim.keymap.set('n', '<Leader>X', ':!chmod +x %<CR>', { noremap = true, silent = true, desc = "Make current file executable" })

-- Key Mappings for Buffer Navigation
vim.keymap.set('n', '<C-[>', ':bprevious<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-]>', ':bnext<CR>', { noremap = true, silent = true })


-- Editing Experience
vim.opt.backspace = {'indent', 'eol', 'start'}
vim.opt.showcmd = true
vim.opt.laststatus = 2
vim.opt.autowrite = true
vim.opt.cursorline = false
vim.opt.autoread = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 10
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.breakindent = true
vim.opt.hlsearch = true
vim.opt.path:append({"**"})
vim.opt.wildignore:append({"*/node_modules/*"})



-- Telescope buffer explorer
vim.keymap.set(
  "n",
  "<S-h>",
  "<cmd>Telescope buffers sort_mru=true sort_lastused=true initial_mode=normal theme=ivy<cr>",
  { desc = "[P]Open telescope buffers" }
)




-- Highlight when yanking
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Tabs and Indentation
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.shiftround = true
vim.opt.expandtab = true

-- Additional Commands
vim.cmd [[ set noswapfile ]]
vim.cmd [[ set termguicolors ]]


-- Backup and Undo
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath('config') .. '/undo'

-- Interface Improvements
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.wrap = false
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.showmode = false

-- Filetype Plugins and Indentation
vim.cmd("filetype plugin indent on")


