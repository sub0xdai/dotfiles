return {
  "nvim-mini/mini.files",
  version = false,
  keys = {
    {
      "-",
      function()
        require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
      end,
      desc = "Open mini.files (Directory of Current File)",
    },
  },
  opts = {
    windows = {
      preview = true,
      width_focus = 30,
      width_preview = 30,
    },
  },
}
