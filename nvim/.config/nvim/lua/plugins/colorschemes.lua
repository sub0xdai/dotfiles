return {
	{
		"zenbones-theme/zenbones.nvim",
		dependencies = "rktjmp/lush.nvim",
		-- Not set as active — switch manually with :colorscheme zenbones (or any variant)
		-- Available: zenbones, zenwritten, neobones, vimbones, rosebones, forestbones,
		--            nordbones, tokyobones, seoulbones, duckbones, zenburned, kanagawabones
		lazy = true,
		config = function()
			-- Every variant needs its own transparent_background set
			local variants = { "zenbones", "zenwritten", "neobones", "vimbones",
				"rosebones", "forestbones", "nordbones", "tokyobones",
				"seoulbones", "duckbones", "zenburned", "kanagawabones" }
			for _, v in ipairs(variants) do
				vim.g[v .. "_transparent_background"] = true
			end
			-- vim.g.zenbones_darken_comments = 45
			-- vim.g.zenbones_lightness = "dim" -- bright | dim | stark | warm
		end,
	},
	{
		"vague2k/vague.nvim",
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
					keyword = "#4f5066",
					string = "#d4bd98",
					--string = "#8a739a",
					--string = "#f2e6ff",
					--number = "#f2e6ff",
					--string = "#d8d5b1",
					number = "#8f729e",
					type = "#dcaed7",

        },
			})
		end,
	},
	{
		"jnurmine/Zenburn",
	},
	{
		"RRethy/base16-nvim",
	},
	{
		"webhooked/kanso.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.opt.termguicolors = true
			-- variants: kanso-zen, kanso-ink, kanso-mist (dark) | kanso-pearl (light)
			require("kanso").setup({
				transparent = true,
				commentStyle = {},
				functionStyle = {},
				keywordStyle = {},
				statementStyle = {},
				typeStyle = {},
				background = {
					dark = "ink",
					light = "pearl",
				},
			})
			vim.cmd("colorscheme kanso-ink")
		end,
	},
}


