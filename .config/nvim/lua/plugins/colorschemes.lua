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
                vim.cmd.colorscheme "catppuccin-frappe"
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
				-- optional configuration here
				transparent = true,
				style = {
					-- "none" is the same thing as default. But "italic" and "bold" are also valid options
					boolean = "none",
					number = "none",
					float = "none",
					error = "none",
					comments = "none",
					conditionals = "none",
					functions = "none",
					headings = "bold",
					operators = "none",
					strings = "none",
					variables = "none",

					-- keywords
					keywords = "none",
					keyword_return = "none",
					keywords_loop = "none",
					keywords_label = "none",
					keywords_exception = "none",

					-- builtin
					builtin_constants = "none",
					builtin_functions = "none",
					builtin_types = "none",
					builtin_variables = "none",
				},
				colors = {
					func = "#bc96b0",
					keyword = "#787bab",
					-- string = "#d4bd98",
					string = "#8a739a",
					-- string = "#f2e6ff",
					-- number = "#f2e6ff",
					-- string = "#d8d5b1",
					number = "#8f729e",
					-- type = "#dcaed7",
				},
			})
      --vim.cmd("colorscheme vague")
		end,
	},
	{
		"jnurmine/Zenburn",
	},
	{
		"RRethy/base16-nvim",
	},
}
