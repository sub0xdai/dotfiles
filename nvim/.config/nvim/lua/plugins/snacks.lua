return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      notifier = { enabled = true },
      picker = {
        enabled = true,
        ui_select = true,
      },
    },
    keys = {
      { "<leader><leader>", function() Snacks.picker.smart() end, desc = "Smart Find" },
      { "<leader>ff", function() Snacks.picker.files({ hidden = true }) end, desc = "Find Files" },
      { "<leader>fg", function() Snacks.picker.grep() end, desc = "Grep" },
      { "<leader>of", function() Snacks.picker.recent() end, desc = "Recent" },
      { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>fz", function() Snacks.picker.lines() end, desc = "Current Buffer" },
      { "<leader>fo", function() Snacks.picker.zoxide() end, desc = "Zoxide" },
      { "<leader>fm", function() Snacks.picker.marks() end, desc = "Marks" },
      { "<leader>gf", function() Snacks.picker.git_files() end, desc = "Git Files" },
      { "<leader>fh", function() Snacks.picker.help() end, desc = "Help" },
      { "<leader>fk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
      { "<leader>fr", function() Snacks.picker.lsp_references() end, desc = "References" },
      { "<leader>ds", function() Snacks.picker.lsp_symbols() end, desc = "Doc Symbols" },
      { "<leader>fs", function() Snacks.picker.lsp_workspace_symbols() end, desc = "Workspace Symbols" },
    },
  },
}
