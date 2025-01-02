return {
  {
    "nvim-telescope/telescope-ui-select.nvim",
  },
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    dependencies = { 
      "nvim-lua/plenary.nvim",
      "jvgrootveld/telescope-zoxide",           
    },
    config = function()
      require("telescope").setup({
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({}),
          },
        },
      })
      local builtin = require("telescope.builtin")
          vim.keymap.set("n", "<leader><leader>", builtin.find_files, {desc="Find"})
          vim.keymap.set("n", "<leader>fg", builtin.live_grep, {desc="Grep"})
          vim.keymap.set("n", "<leader>of", builtin.oldfiles, {desc="Recent"})
          vim.keymap.set('n', '<leader>fb', builtin.buffers, {desc="Buffers"})
          vim.keymap.set("n", "<leader>fz", builtin.current_buffer_fuzzy_find, {desc="Current"})
          vim.keymap.set("n", "<leader>fo", [[<cmd>lua require('telescope').extensions.zoxide.list()<CR>]], {desc="Zoxide"})
          vim.keymap.set("n", "<leader>fm", builtin.marks, {desc="Marks"})
          vim.keymap.set("n", "<leader>gf", builtin.git_files, {desc="GitFiles"})
          vim.keymap.set("n", "<leader>fh", builtin.help_tags, {desc="Help"})
          vim.keymap.set("n", "<leader>fk", builtin.keymaps, {desc="Maps"})
          vim.keymap.set("n", "<leader>fr", builtin.lsp_references, {desc="References"})
          vim.keymap.set("n", "<leader>fd", builtin.lsp_definitions, {desc="Definitions"})
          vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, {desc="Symbols"})

      require("telescope").load_extension("ui-select")
      require("telescope").load_extension("zoxide")
    end,
  },
}


-- Explanation of Key Mappings:

-- 1. <leader>ff- Find Files
--    - Opens a fuzzy search window to find files in the current working directory.

-- 2. <leader>fg - Live Grep
--    - Performs a global search by searching for a string across all files in the project using `rg` (ripgrep).

-- 3. <leader><leader> - Old Files
--    - Lists recently opened files, useful for quickly accessing files you've worked on before.

-- 4. <leader>fb - Find Buffers
--    - Shows a list of open buffers, allowing you to switch between them easily.

-- 5. <leader>fz - Current Buffer Fuzzy Find
--    - Searches within the currently open file for a string, allowing you to jump to a specific location in the file.
--
-- 6. <leader>gf - Git Files
--    - Quickly finds and lists all files tracked by Git.

-- 7. <leader>fh - Find Help Tags
--    - Opens a fuzzy finder for Neovim's help tags, allowing you to search for specific help documentation.

-- 8. <leader>fm - Find Keymaps
--    - Lists all available key mappings in your Neovim configuration for easy reference.

-- LSP Mappings:

-- 9. <leader>fr - Find References
--     - Lists all references to the symbol under your cursor across the project, useful for tracing function usage.

-- 10. <leader>fd - Find Definitions
--     - Jumps to the definition of the symbol under your cursor (e.g., function, variable).

-- 11. <leader>fs - Document Symbols
--     - Lists all symbols in the current file (functions, classes, etc.) for quick navigation.

-- 12. <leader>fw - Workspace Symbols
--     - Lists all symbols across the entire project, allowing for project-wide symbol search.

-- 13. <leader>fx - Diagnostics
--     - Displays a list of current LSP diagnostics (errors, warnings) in the project or file.

