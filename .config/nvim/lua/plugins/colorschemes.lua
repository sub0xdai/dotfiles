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
              -- vim.cmd.colorscheme "catppuccin-mocha"
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
           -- vim.cmd("colorscheme tokyonight")
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
                boolean = "none",
                number = "none",
                float = "none",
                error = "none",
                comments = "italic",
                conditionals = "none",
                functions = "italic",
                headings = "bold",
                operators = "none",
                strings = "none",
                variables = "none",
                keywords = "none",
            },
            colors = {
                -- Enhanced contrast for core syntax
                func = "#e4c5dc",            -- Brighter pink for functions
                keyword = "#cba6f7",         -- Catppuccin Mauve for keywords
                string = "#d4c1e6",          -- Brighter strings
                number = "#af92be",          -- Enhanced numbers
                type = "#b6a9bd",            -- Brighter types
                constant = "#c1a6c3",        -- Enhanced constants
                parameter = "#d5c0d2",       -- Brighter parameters
                operator = "#b593a9",        -- Enhanced operators
                special_char = "#c49ab1",    -- Brighter special chars
                variable = "#c3b4ca",        -- Enhanced variables
                -- Improved diagnostic colors
                diagnostic = "#e4b5c5",
                comment = "#8d8daf",         -- Slightly brighter comments
                warning = "#e6c9dc",
                error = "#d5aac3",
                -- Enhanced UI elements
                selection = "#afa2b9",
                cursor = "#d8c6d5",
                pmenu = "#b6aac3",
            },
            highlights = {
                -- Enhanced TreeSitter groups
                ["@module"] = { fg = "#cba6f7" },         -- For module names in chains
                ["@namespace"] = { fg = "#cba6f7" },      -- For namespace parts
                ["@method.call"] = { fg = "#e4c5dc" },    -- Keep method calls in original color
                
                -- Basic punctuation groups
                ["@punctuation"] = { fg = "#fab387" },               -- Base color for all punctuation
                ["@punctuation.bracket"] = { fg = "#74c7ec" },       -- All kinds of brackets
                ["@punctuation.special"] = { fg = "#94e2d5" },       -- Special punctuation
                
                ["@field.key"] = { fg = "#cba6f7" },     -- For table keys
                ["@function"] = { fg = "#e4c5dc" },
                ["@function.builtin"] = { fg = "#e4c5dc" },
                ["@string"] = { fg = "#d4c1e6" },
                ["@number"] = { fg = "#af92be" },
                ["@boolean"] = { fg = "#af92be" },
                ["@type"] = { fg = "#b6a9bd" },
                ["@keyword"] = { fg = "#cba6f7" },
                ["@variable"] = { fg = "#c3b4ca" },
                ["@parameter"] = { fg = "#d5c0d2" },
                ["@constant"] = { fg = "#c1a6c3" },
                ["@comment"] = { fg = "#8d8daf", italic = true },
                -- Enhanced punctuation contrast
                ["@punctuation.delimiter"] = { fg = "#b593a9" },
                ["@character.special"] = { fg = "#c49ab1" },

                -- Enhanced diagnostic highlights
                DiagnosticError = { fg = "#e4b5c5" },
                DiagnosticWarn = { fg = "#d8c0d0" },
                DiagnosticInfo = { fg = "#c8b2c5" },
                DiagnosticHint = { fg = "#baa7b7" },
            },
        })
         vim.cmd("colorscheme vague")
    end,
}
}
