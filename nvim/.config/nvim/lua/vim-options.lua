vim = vim or {}

-- General Settings
vim.g.mapleader = " "
vim.g.maplocalleader = ' '
vim.g.background = "light"

vim.opt.swapfile = false
vim.opt.clipboard = 'unnamedplus'   -- use system clipboard
vim.opt.splitbelow = true           -- open new vertical split bottom
vim.opt.splitright = true           -- open new horizontal splits right
vim.opt.splitkeep = "cursor"
vim.wo.number = true

-- Window navigation
vim.keymap.set('n', '<c-k>', '<cmd>wincmd k<CR>', { silent = true })
vim.keymap.set('n', '<c-j>', '<cmd>wincmd j<CR>', { silent = true })
vim.keymap.set('n', '<c-h>', '<cmd>wincmd h<CR>', { silent = true })
vim.keymap.set('n', '<c-l>', '<cmd>wincmd l<CR>', { silent = true })

-- Clear search highlight
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { silent = true })

-- New vertical split
vim.keymap.set('n', '<C-n>', '<cmd>vnew<CR>', { noremap = true, silent = true })

-- File operations
vim.keymap.set('n', '<Leader>X', '<cmd>!chmod +x %<CR>', { noremap = true, silent = true, desc = "Make current file executable" })
vim.keymap.set('n', '<Leader>cpf', '<cmd>let @+ = expand("%:p")<CR>', { noremap = true, silent = true, desc = "Copy full path of current file" })
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- Dadbod + ui 
-- Open the database UI
vim.keymap.set('n', '<leader>db', ':DBUI<CR>', { noremap = true })
-- Save connection
vim.keymap.set('n', '<leader>ds', ':DBUIAddConnection<CR>', { noremap = true })
-- Toggle the database UI
vim.keymap.set('n', '<leader>dt', ':DBUIToggle<CR>', { noremap = true })
-- Find buffer
vim.keymap.set('n', '<leader>df', ':DBUIFindBuffer<CR>', { noremap = true })
-- Rename buffer
vim.keymap.set('n', '<leader>dr', ':DBUIRenameBuffer<CR>', { noremap = true })
-- Last query info
vim.keymap.set('n', '<leader>dl', ':DBUILastQueryInfo<CR>', { noremap = true })
-- Execute query under cursor
vim.keymap.set('n', '<leader>de', ':DB<CR>', { noremap = true })
-- Execute the entire buffer as a query
vim.keymap.set('n', '<leader>da', ':w !DB<CR>', { noremap = true })

-- Create a new file with prompt for filename
vim.keymap.set('n', '<Leader>nf', function()
  vim.ui.input({
    prompt = "Enter new file name: ",
  }, function(input)
    if input then
      -- Create and edit the new file
      vim.cmd('edit ' .. input)
    end
  end)
end, { noremap = true, silent = true, desc = "Create new file" })

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


-- Terminal config (nvim)
local sub0xterm = require('plugins.sub0xterm')

vim.keymap.set("n", "<space>st", ":ToggleFloatingTerminal<CR>", { desc = "Toggle Floating Terminal", silent = true })

vim.api.nvim_create_autocmd("TermOpen", {
    group = vim.api.nvim_create_augroup("Sub0xTerminal", { clear = true }),
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
    end,
})


-- Tabs and Indentation - globally
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.shiftround = true
vim.opt.expandtab = true

-- File type specific indentation
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.tabstop = 3
    vim.opt_local.shiftwidth = 3
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = {"python", "c", "cpp", "cs", "h", "hpp", "php", "rust", "xml", "dockerfile"},
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
})

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
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.showmode = false

-- Filetype Plugins and Indentation
vim.cmd("filetype plugin indent on")
