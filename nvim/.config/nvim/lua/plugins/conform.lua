return {
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
          javascript = { "biome" },
          typescript = { "biome" },
          javascriptreact = { "biome" },
          typescriptreact = { "biome" },
          css = { "biome" },
          html = { "biome" },
          json = { "biome" },
          yaml = { "biome" },
          markdown = { "biome" },
          typst = { "typstyle" },
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
}
