-- lua/plugins/colorschemes.lua

return {
    {
        "catppuccin/nvim",
        lazy = false,
        name = "catppuccin",
        priority = 1000,
        opts = {
            term_colors = true,
            transparent_background = true,
            dim_inactive = {
                enabled = false,
                shade = "dark",
                percentage = 01,
            },
            config = function()
             vim.cmd.colorscheme "catppuccin-mocha"
            end
        }
    },
    {
        "rose-pine/neovim",
        lazy = false,
        name = "rose-pine",
        priority = 1000,
        config = function()
            require("rose-pine").setup({
                variant = "moon",
                dark_variant = "main",
                dim_inactive_windows = false,
                extend_background_behind_borders = true,
                enable = {
                    terminal = true,
                    legacy_highlights = true,
                    migrations = true,
                },
                styles = {
                    bold = true,
                    italic = true,
                    transparency = true,
                },
                groups = {
                    border = "muted",
                    link = "iris",
                    panel = "surface",
                    error = "love",
                    hint = "iris",
                    info = "foam",
                    note = "pine",
                    todo = "rose",
                    warn = "gold",
                    git_add = "foam",
                    git_change = "rose",
                    git_delete = "love",
                    git_dirty = "rose",
                    git_ignore = "muted",
                    git_merge = "iris",
                    git_rename = "pine",
                    git_stage = "iris",
                    git_text = "rose",
                    git_untracked = "subtle",
                    h1 = "iris",
                    h2 = "foam",
                    h3 = "rose",
                    h4 = "gold",
                    h5 = "pine",
                    h6 = "foam",
                },
                highlight_groups = {
                    -- Custom highlight groups can be added here
                },
                before_highlight = function(group, highlight, palette)
                    -- Custom modifications before applying highlights
                end,
            })
             -- vim.cmd("colorscheme rose-pine")
        end
    },
    {
        "folke/tokyonight.nvim",
        lazy = false,
        name = "tokyonight",
        priority = 1000,
        config = function()
            require("tokyonight").setup({
                style = "night",  -- Choose between "night", "storm", "day", or "moon"
                transparent = true,  -- Enable transparency
                styles = {
                    sidebars = "transparent",
                    floats = "transparent",
                },
                on_highlights = function(hl, c)
                    -- Custom highlight modifications can be added here
                end,
            })
            --vim.cmd("colorscheme tokyonight")
        end
    },
    {
        "maxmx03/dracula.nvim",
        lazy = false,
        name = "dracula",
        priority = 1000,
        config = function()
            require("dracula").setup({
                transparent = true,  -- Enable transparency
            })
            --vim.cmd("colorscheme dracula")
        end
    },
    {
        "navarasu/onedark.nvim",
        lazy = false,
        name = "onedark",
        priority = 1000,
        config = function()
            require("onedark").setup({
                style = "dark",  -- Choose between 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer', 'light'
                transparent = true,  -- Enable transparency
                term_colors = true,  -- Set terminal colors
                ending_tildes = false,  -- Show end-of-buffer tildes
                cmp_itemkind_reverse = false,  -- Reverse item kind highlights in cmp menu
                code_style = {
                    comments = "italic",
                    keywords = "bold",
                    functions = "none",
                    strings = "none",
                    variables = "none"
                },
                colors = {},  -- Override default colors
                highlights = {},  -- Override highlight groups
                diagnostics = {
                    darker = true,
                    undercurl = true,
                    background = true,
                },
            })
          -- vim.cmd("colorscheme onedark")
        end
    },


	{
    "vague2k/vague.nvim",
    lazy = false,
    name = "vague",
    priority = 1000,
    config = function()
        require("vague").setup({
            transparent = true,
            style = {
                -- Base styles
                boolean = "none",
                number = "none",
                float = "none",
                error = "none",
                comments = "italic",  -- Added italic for better code readability
                conditionals = "none",
                functions = "italic",
                headings = "bold",
                operators = "none",
                strings = "none",
                variables = "none",
                -- Keywords
                keywords = "none",
                keyword_return = "none",
                keywords_loop = "none",
                keywords_label = "none",
                keywords_exception = "none",
                -- Builtin elements
                builtin_constants = "none",
                builtin_functions = "none",
                builtin_types = "none",
                builtin_variables = "none",
            },
            colors = {
                -- Core syntax elements
                func = "#bc96b0",            -- Soft pink for functions
                keyword = "#787bab",         -- Muted purple for keywords
                string = "#8a739a",          -- Dusty purple for strings
                number = "#8f729e",          -- Deep lavender for numbers
                -- Additional syntax elements
                type = "#9a8fa3",           -- Soft mauve for types
                constant = "#a686a3",       -- Muted rose for constants
                parameter = "#b5a0b2",      -- Light plum for parameters
                operator = "#8b7b96",       -- Grayed purple for operators
                variable = "#a394aa",       -- Gentle purple for variables 
                -- Special elements
                comment = "#6d6d8f",        -- Muted blue-gray for comments
                warning = "#c6a9bc",        -- Light rose for warnings
                error = "#b58aa3",          -- Deeper rose for errors  
                -- UI elements
                selection = "#8f8299",      -- Muted purple for selections
                cursor = "#b8a6b5",         -- Light mauve for cursor
                pmenu = "#968aa3",          -- Soft purple for popup menu
            },
        })
        -- vim.cmd("colorscheme vague")
    end,
  }
}
