return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup()

      -- Install parsers (async, no-op if already installed)
      require("nvim-treesitter").install({
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
      })

      -- Enable treesitter highlighting per filetype via autocommand
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "lua", "typst", "go", "rust", "python", "javascript",
          "typescript", "c", "cpp", "bash", "zig", "haskell",
          "latex", "json", "yaml", "toml", "html", "css", "sql",
          "prisma", "gleam", "nim", "wgsl",
          "markdown", "markdown_inline", "vim",
        },
        callback = function()
          vim.treesitter.start()
        end,
      })
    end,
  },
}
