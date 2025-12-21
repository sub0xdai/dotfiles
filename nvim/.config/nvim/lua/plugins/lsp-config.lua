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
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					--"nil_ls",
					"bashls",
					"lua_ls",
					"rust_analyzer",
					"gopls",
					"templ",
					"html",
					"cssls",
					"emmet_language_server",
					"htmx",
					"tailwindcss",
					"ts_ls",
					-- "tsserver",
					"pylsp",
					"clangd",
					"prismals",
					"yamlls",
					"jsonls",
					"eslint",
					-- "hls",
					"zls",
					"marksman",
					"sqlls",
					"wgsl_analyzer",
					"texlab",
					"intelephense",
					"nim_langserver",
				},
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			local function get_python_path()
				local venv_path = os.getenv("VIRTUAL_ENV")
				if venv_path then
					return venv_path .. "/bin/python3"
				else
					local os_name = require("utils").get_os()
					if os_name == "windows" then
						return "C:/python312"
					elseif os_name == "linux" then
						return "/usr/bin/python3"
					else
						return nil
					end
				end
			end

			-- LSP configs using vim.lsp.config (new API)
			vim.lsp.config.sqlls = { capabilities = capabilities }
			vim.lsp.config.intelephense = { capabilities = capabilities }
			vim.lsp.config.texlab = { capabilities = capabilities }
			vim.lsp.config.zls = { capabilities = capabilities, cmd = { "zls" } }
			vim.lsp.config.hls = { capabilities = capabilities, single_file_support = true }
			vim.lsp.config.bashls = { capabilities = capabilities }
			vim.lsp.config.lua_ls = {
				capabilities = capabilities,
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
						workspace = { library = vim.api.nvim_get_runtime_file("", true) },
						telemetry = { enable = false },
					},
				},
			}
			vim.lsp.config.wgsl_analyzer = { capabilities = capabilities }
			vim.lsp.config.jsonls = { capabilities = capabilities }
			vim.lsp.config.gopls = { capabilities = capabilities }
			vim.lsp.config.cssls = { capabilities = capabilities }
			vim.lsp.config.prismals = { capabilities = capabilities }
			vim.lsp.config.yamlls = { capabilities = capabilities }
			vim.lsp.config.html = {
				capabilities = capabilities,
				filetypes = { "templ", "html", "php", "css", "javascriptreact", "typescriptreact", "javascript", "typescript", "jsx", "tsx" },
			}
			vim.lsp.config.htmx = {
				capabilities = capabilities,
				filetypes = { "html", "templ" },
			}
			vim.lsp.config.emmet_language_server = {
				capabilities = capabilities,
				filetypes = { "templ", "html", "css", "php", "javascriptreact", "typescriptreact", "javascript", "typescript", "jsx", "tsx", "markdown" },
			}
			vim.lsp.config.tailwindcss = {
				capabilities = capabilities,
				filetypes = { "templ", "html", "css", "javascriptreact", "typescriptreact", "javascript", "typescript", "jsx", "tsx" },
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
			}
			vim.lsp.config.templ = {
				capabilities = capabilities,
				filetypes = { "templ" },
			}
			vim.lsp.config.ts_ls = { capabilities = capabilities }
			vim.lsp.config.eslint = { capabilities = capabilities }
			vim.lsp.config.clangd = {
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
				capabilities = capabilities,
				single_file_support = true,
			}
			vim.lsp.config.pylsp = {
				capabilities = capabilities,
				settings = {
					python = { pythonPath = get_python_path() },
				},
			}
			vim.lsp.config.marksman = { capabilities = capabilities }
			vim.lsp.config.gleam = { capabilities = capabilities }
			vim.lsp.config.nim_langserver = { capabilities = capabilities }

			-- Enable all configured servers
			vim.lsp.enable({
				"sqlls",
				"intelephense",
				"texlab",
				"zls",
				"hls",
				"bashls",
				"lua_ls",
				"wgsl_analyzer",
				"jsonls",
				"gopls",
				"cssls",
				"prismals",
				"yamlls",
				"html",
				"htmx",
				"emmet_language_server",
				"tailwindcss",
				"templ",
				"ts_ls",
				"eslint",
				"clangd",
				"pylsp",
				"marksman",
				"gleam",
				"nim_langserver",
			})
		end,
	},
}
