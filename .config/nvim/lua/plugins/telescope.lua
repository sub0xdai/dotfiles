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
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make"
      }
    },
    config = function()
      local actions = require("telescope.actions")
      local action_layout = require("telescope.actions.layout")

      -- Path display helper functions
      local function normalize_path(path)
        return path:gsub("\\", "/")
      end

      local function normalize_cwd()
        return normalize_path(vim.loop.cwd()) .. "/"
      end

      local function is_subdirectory(cwd, path)
        return string.lower(path:sub(1, #cwd)) == string.lower(cwd)
      end

      local function split_filepath(path)
        local normalized_path = normalize_path(path)
        local normalized_cwd = normalize_cwd()
        local filename = normalized_path:match("[^/]+$")

        if is_subdirectory(normalized_cwd, normalized_path) then
          local stripped_path = normalized_path:sub(#normalized_cwd + 1, -(#filename + 1))
          return stripped_path, filename
        else
          local stripped_path = normalized_path:sub(1, -(#filename + 1))
          return stripped_path, filename
        end
      end

      local function path_display(_, path)
        local stripped_path, filename = split_filepath(path)
        if filename == stripped_path or stripped_path == "" then
          return filename
        end
        return string.format("%s ~ %s", filename, stripped_path)
      end

      -- Git-aware file finding functions
      local function is_git_repo()
        vim.fn.system("git rev-parse --is-inside-work-tree")
        return vim.v.shell_error == 0
      end

      -- Function to check if we're in a git repo and fallback to find_files if not
      local function project_files()
        local opts = {}
        local ok = pcall(require("telescope.builtin").git_files, opts)
        if not ok then
          require("telescope.builtin").find_files(opts)
        end
      end

      local telescopeConfig = require("telescope.config")
      
      -- Clone the default Telescope configuration
      local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }
      -- Don't search in the `.git` directory.
      table.insert(vimgrep_arguments, "--glob")
      table.insert(vimgrep_arguments, "!**/.git/*")
      -- Add trim option for better performance
      table.insert(vimgrep_arguments, "--trim")

      require("telescope").setup({
        defaults = {
          vimgrep_arguments = vimgrep_arguments,
          path_display = path_display,
          mappings = {
            i = {
              ["<esc>"] = actions.close,
              ["<C-u>"] = false,
              ["<M-p>"] = action_layout.toggle_preview
            }
          },
          -- Performance optimizations
          file_ignore_patterns = {
            "%.git/",
            "node_modules",
            "%.cache",
            "%.o",
            "%.a",
            "%.out",
            "%.class",
            "%.pdf",
            "%.mkv",
            "%.mp4",
            "%.zip"
          },
          preview = {
            filesize_limit = 0.2, -- MB
            timeout = 250, -- ms
          },
          -- Don't preview binary files
          buffer_previewer_maker = function(filepath, bufnr, opts)
            opts = opts or {}
            -- Skip preview for large files
            if opts.filesize_limit and opts.filesize_limit < (vim.fn.getfsize(filepath) / 1024 / 1024) then
              return false
            end
            -- Skip preview for binary files
            local mime_type = vim.fn.system({"file", "--mime-type", "-b", filepath})
            if mime_type:match("^binary") then
              return false
            end
            require("telescope.previewers").buffer_previewer_maker(filepath, bufnr, opts)
          end
        },
        pickers = {
          find_files = {
            hidden = true,
            find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*", "--trim" },
            -- Fallback command if fd is not available
            -- find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
            path_display = { "truncate" },
            layout_config = {
              height = 0.75,
              prompt_position = "top",
            },
          },
          buffers = {
            show_all_buffers = true,
            sort_lastused = true,
            mappings = {
              i = {
                ["<c-d>"] = actions.delete_buffer,
              }
            }
          }
        },
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({}),
          },
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
          path_display = {
            "filename_first",
          },
          zoxide = {
          }
        },
      })
      local builtin = require("telescope.builtin")
      -- Improved file finding keymaps
      vim.keymap.set("n", "<leader><leader>", project_files, {desc="Smart Find"})
      vim.keymap.set("n", "<leader>ff", builtin.find_files, {desc="Find Files"})
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

      -- Load extensions
      require("telescope").load_extension("ui-select")
      require("telescope").load_extension("fzf")
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
