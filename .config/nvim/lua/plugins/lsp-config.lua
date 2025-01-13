return {
  -- Mason for managing LSP servers, DAP servers, linters, and formatters
  {
    "williamboman/mason.nvim",
    lazy = false,
    config = function()
      require("mason").setup()
    end
  },
  -- Mason-lspconfig for easier LSP server setup
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    opts = {
      ensure_installed = {
        "pyright",
        "html",
        "lua_ls",
        "clangd",
        "solargraph",
        "gopls",
        "marksman",
        "bashls",
        "yamlls",
        "jsonls",
        "terraformls",
        "dockerls"
              },
      automatic_installation = true,
    },
  },
  -- LSP configuration
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      local lspconfig = require("lspconfig")
      local servers = { "pyright", "html", "lua_ls", "clangd", "solargraph", "gopls", "marksman", "bashls", "yamlls", "jsonls", "terraformls", "dockerls"  }
      for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup({
          capabilities = capabilities
        })
      end
      -- LSP Keybindings
      vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover Documentation" })
      vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
      vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, { desc = "Find References" })
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
    end,
  },
  -- Treesitter for better syntax highlighting and code understanding
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "go", "python", "lua", "c", "cpp", "ruby", "html" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
  -- Formatter
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local conform = require("conform")
      conform.setup({
        formatters_by_ft = {
          go = { "gofmt" },
          python = { "black" },
          lua = { "stylua" },
          -- Add formatters for other languages as needed
        },
      })
      vim.keymap.set({ "n", "v" }, "<leader>l", function()
        conform.format({
          lsp_fallback = true,
          async = false,
          timeout_ms = 1000,
        })
      end, { desc = "Format file or range (in visual mode)" })
    end,
  },
  -- Debugger
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "leoluz/nvim-dap-go",
      "rcarriga/nvim-dap-ui",
    },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      require("dap-go").setup()
      dapui.setup()
      
      -- Debugging keymaps
      vim.keymap.set("n", "<leader>dt", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Start/Continue Debugging" })
      vim.keymap.set("n", "<leader>do", dapui.toggle, { desc = "Toggle Debug UI" })
      
      -- Automatically open dapui when debugging starts
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },
}
