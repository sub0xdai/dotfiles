return {
	{
		"vague2k/vague.nvim",
		config = function()
			vim.opt.termguicolors = true
			vim.cmd('colorscheme base16-black-metal-khold')
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
}


