return {
  "stevearc/oil.nvim",
  config = function()
    local oil = require("oil")
    local actions = require("oil.actions")

    oil.setup({
      keymaps = {
        -- Custom keymaps
        ["<leader>v"] = { actions.select, opts = { vertical = true }, desc = "Open current file in a vertical split" },
        ["<leader>b"] = actions.parent, -- Go back to the parent directory
        ["a"] = actions.create, -- Create a new file or directory
        ["m"] = actions.move, -- Move or rename a ile
        ["y"] = actions.copy, -- Copy a file
        ["p"] = actions.paste, -- Paste a copied or cut file
        ["d"] = actions.delete, -- Delete a file
        ["<esc>"] = actions.close, -- Close the oil buffer on Escape
        ["<C-p>"] = actions.preview,
       },
    })

    vim.keymap.set("n", "-", oil.toggle_float, {})
  end,
}

