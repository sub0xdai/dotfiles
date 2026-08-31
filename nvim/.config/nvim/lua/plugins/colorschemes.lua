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
		-- Not active - switch manually with :colorscheme kanso-ink
		-- variants: kanso-zen, kanso-ink, kanso-mist (dark) | kanso-pearl (light)
		config = function()
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
		end,
	},
	{
		"oskarnurm/koda.nvim",
		-- variants: koda (auto dark/light), koda-dark, koda-light, koda-moss, koda-glade
		lazy = false,
		priority = 1000,
		config = function()
			require("koda").setup({ transparent = true })
			-- Persisted pick from <leader>tc; fallback default below.
			-- Change this line to set a new startup default theme.
			local theme_file = vim.fn.stdpath("data") .. "/base_theme.txt"
			local fh = io.open(theme_file, "r")
			local saved = fh and fh:read("*l") or nil
			if fh then
				fh:close()
			end
			-- boundary parse: only accept a sane colorscheme name
			local base_theme = saved and saved:match("^[%w_%-]+$") or "koda"
			if not pcall(vim.cmd, "colorscheme " .. base_theme) then
				base_theme = "koda"
				vim.cmd("colorscheme koda")
			end

			-- Monochrome markdown: switch to zenwritten (monochrome zenbones)
			-- for markdown buffers, back to base_theme elsewhere. Toggle <leader>tm.
			local md_mono = true
			local current = base_theme
			local function set_scheme(name)
				if current ~= name then
					vim.cmd("colorscheme " .. name)
					current = name
				end
			end

			vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
				callback = function()
					-- schedule: lazy.nvim's colorscheme autoload isn't active
					-- during startup buffer events
					vim.schedule(function()
						if vim.bo.filetype == "markdown" then
							if md_mono then
								set_scheme("zenwritten")
							end
						elseif current == "zenwritten" then
							set_scheme(base_theme)
						end
					end)
				end,
			})

			vim.keymap.set("n", "<leader>tm", function()
				md_mono = not md_mono
				if vim.bo.filetype == "markdown" then
					set_scheme(md_mono and "zenwritten" or base_theme)
				end
			end, { desc = "Toggle monochrome (zenwritten) markdown theme" })

			-- Theme selector: pick any installed colorscheme with live preview.
			-- The pick becomes the base theme for the markdown swap too.
			vim.keymap.set("n", "<leader>tc", function()
				Snacks.picker.colorschemes({
					confirm = function(picker, item)
						picker:close()
						if item then
							picker.preview.state.colorscheme = nil
							vim.schedule(function()
								vim.cmd("colorscheme " .. item.text)
								base_theme = item.text
								current = item.text
								local f = io.open(theme_file, "w")
								if f then
									f:write(item.text)
									f:close()
								end
							end)
						end
					end,
				})
			end, { desc = "Theme picker (colorscheme selector)" })
		end,
	},
}


