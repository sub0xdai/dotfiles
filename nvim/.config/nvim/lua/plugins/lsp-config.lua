return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup({
				PATH = "prepend",
			})
		end,
	},
	{
		-- Native LSP configuration (no nvim-lspconfig needed)
		-- Each server needs cmd + filetypes since 0.12 ships no built-in defaults
		name = "native-lsp",
		dir = vim.fn.stdpath("config"),
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			local function get_python_path()
				local venv_path = os.getenv("VIRTUAL_ENV")
				if venv_path then
					return venv_path .. "/bin/python3"
				end
				return "/usr/bin/python3"
			end

			vim.lsp.config("*", {
				root_markers = { ".git" },
			})

			-- Shell
			vim.lsp.config("bashls", {
				cmd = { "bash-language-server", "start" },
				filetypes = { "sh", "bash" },
			})

			-- Lua
			vim.lsp.config("lua_ls", {
				cmd = { "lua-language-server" },
				filetypes = { "lua" },
				settings = { Lua = { telemetry = { enable = false } } },
			})

			-- Go
			vim.lsp.config("gopls", {
				cmd = { "gopls" },
				filetypes = { "go", "gomod", "gowork", "gotmpl" },
			})

			-- Rust
			-- rust-analyzer is handled by rustaceanvim or installed via rustup

			-- C/C++
			vim.lsp.config("clangd", {
				cmd = {
					"clangd",
					"--background-index",
					"--pch-storage=memory",
					"--all-scopes-completion",
					"--pretty",
					"--header-insertion=never",
					"-j=4",
					"--inlay-hints",
					"--header-insertion-decorators",
					"--function-arg-placeholders",
					"--completion-style=detailed",
				},
				filetypes = { "c", "cpp", "objc", "objcpp" },
				root_markers = { "src" },
				init_options = { fallbackFlags = { "-std=c++2a" } },
				single_file_support = true,
			})

			-- Python
			vim.lsp.config("pylsp", {
				cmd = { "pylsp" },
				filetypes = { "python" },
				settings = { python = { pythonPath = get_python_path() } },
			})

			-- TypeScript / JavaScript
			vim.lsp.config("ts_ls", {
				cmd = { "typescript-language-server", "--stdio" },
				filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
			})

			vim.lsp.config("eslint", {
				cmd = { "vscode-eslint-language-server", "--stdio" },
				filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
			})

			-- Web
			vim.lsp.config("html", {
				cmd = { "vscode-html-language-server", "--stdio" },
				filetypes = { "html", "templ", "php", "css", "javascriptreact", "typescriptreact", "javascript", "typescript" },
			})

			vim.lsp.config("cssls", {
				cmd = { "vscode-css-language-server", "--stdio" },
				filetypes = { "css", "scss", "less" },
			})

			vim.lsp.config("htmx", {
				cmd = { "htmx-lsp" },
				filetypes = { "html", "templ" },
			})

			vim.lsp.config("emmet_language_server", {
				cmd = { "emmet-language-server", "--stdio" },
				filetypes = { "html", "templ", "css", "php", "javascriptreact", "typescriptreact", "javascript", "typescript", "markdown" },
			})

			vim.lsp.config("tailwindcss", {
				cmd = { "tailwindcss-language-server", "--stdio" },
				filetypes = { "html", "templ", "css", "javascriptreact", "typescriptreact", "javascript", "typescript" },
				root_markers = {
					"tailwind.config.js",
					"tailwind.config.cjs",
					"tailwind.config.mjs",
					"tailwind.config.ts",
					"postcss.config.js",
					"postcss.config.cjs",
					"postcss.config.mjs",
					"postcss.config.ts",
					"package.json",
					"node_modules",
					".git",
				},
			})

			vim.lsp.config("templ", {
				cmd = { "templ", "lsp" },
				filetypes = { "templ" },
			})

			-- Data
			vim.lsp.config("jsonls", {
				cmd = { "vscode-json-language-server", "--stdio" },
				filetypes = { "json", "jsonc" },
			})

			vim.lsp.config("yamlls", {
				cmd = { "yaml-language-server", "--stdio" },
				filetypes = { "yaml", "yaml.docker-compose" },
			})

			vim.lsp.config("sqlls", {
				cmd = { "sql-language-server", "up", "--method", "stdio" },
				filetypes = { "sql", "mysql" },
			})

			vim.lsp.config("prismals", {
				cmd = { "prisma-language-server", "--stdio" },
				filetypes = { "prisma" },
			})

			-- PHP
			vim.lsp.config("intelephense", {
				cmd = { "intelephense", "--stdio" },
				filetypes = { "php" },
			})

			-- Zig
			vim.lsp.config("zls", {
				cmd = { "zls" },
				filetypes = { "zig", "zir" },
			})

			-- Haskell
			vim.lsp.config("hls", {
				cmd = { "haskell-language-server-wrapper", "--lsp" },
				filetypes = { "haskell", "lhaskell" },
				single_file_support = true,
			})

			-- LaTeX
			vim.lsp.config("texlab", {
				cmd = { "texlab" },
				filetypes = { "tex", "plaintex", "bib" },
			})

			-- WGSL
			vim.lsp.config("wgsl_analyzer", {
				cmd = { "wgsl_analyzer" },
				filetypes = { "wgsl" },
			})

			-- Gleam
			vim.lsp.config("gleam", {
				cmd = { "gleam", "lsp" },
				filetypes = { "gleam" },
			})

			-- Nim
			vim.lsp.config("nim_langserver", {
				cmd = { "nimlangserver" },
				filetypes = { "nim" },
			})

			-- Typst
		vim.lsp.config("tinymist", {
			cmd = { "tinymist" },
			filetypes = { "typst" },
			single_file_support = true,
		})

		-- Markdown (PKM-focused LSP for Obsidian-style vaults)
			vim.lsp.config("markdown_oxide", {
				cmd = { "markdown-oxide" },
				filetypes = { "markdown" },
				capabilities = {
					workspace = {
						didChangeWatchedFiles = { dynamicRegistration = true },
					},
				},
				on_attach = function(client, bufnr)
					vim.api.nvim_create_user_command("Daily", function(args)
						vim.lsp.buf.execute_command({ command = "jump", arguments = { args.args } })
					end, { desc = "Open daily note", nargs = "*" })

					if client.server_capabilities.codeLensProvider then
						vim.lsp.codelens.enable(true, { bufnr = bufnr })
					end
				end,
			})

			-- Enable all servers
			vim.lsp.enable({
				"tinymist",
				"bashls",
				"lua_ls",
				"gopls",
				"clangd",
				"pylsp",
				"ts_ls",
				"eslint",
				"html",
				"cssls",
				"htmx",
				"emmet_language_server",
				"tailwindcss",
				"templ",
				"jsonls",
				"yamlls",
				"sqlls",
				"prismals",
				"intelephense",
				"zls",
				"hls",
				"texlab",
				"wgsl_analyzer",
				"gleam",
				"nim_langserver",
				"markdown_oxide",
			})

			-- Native completion on LspAttach
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client and client:supports_method("textDocument/completion") then
						vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
					end
				end,
			})
		end,
	},
}
