return {
  "vim-test/vim-test",
  dependencies = {
    "preservim/vimux"
  },
  config = function()
    vim.keymap.set("n", "<leader>ts", ":TestNearest<CR>", { desc = "Test Nearest" })
    vim.keymap.set("n", "<leader>TS", ":TestFile<CR>", { desc = "Test File" })
    vim.keymap.set("n", "<leader>ta", ":TestSuite<CR>", { desc = "Test Suite (All)" })
    vim.keymap.set("n", "<leader>tl", ":TestLast<CR>", { desc = "Test Last" })
    vim.keymap.set("n", "<leader>tv", ":TestVisit<CR>", { desc = "Test Visit" })
    vim.cmd("let test#strategy = 'vimux'")
  end,
}
