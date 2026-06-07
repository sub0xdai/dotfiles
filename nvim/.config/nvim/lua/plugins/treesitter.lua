return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = {
          "lua",
          "typst",
          "go",
          "rust",
          "python",
          "javascript",
          "typescript",
          "c",
          "cpp",
          "bash",
          "zig",
          "haskell",
          "latex",
          "json",
          "yaml",
          "toml",
          "html",
          "css",
          "sql",
          "prisma",
          "gleam",
          "nim",
          "wgsl",
        },
        auto_install = false,
        highlight = { enable = true },
        indent = { enable = false },
      })
    end,
  },
}
