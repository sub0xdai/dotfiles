return {
    dir = vim.fn.stdpath("config") .. "/lua/cool_stuff",
    name = "todo_float",
    config = function()
        require("cool_stuff.todo_float").setup({
            target_file = "~/notes/todo.md",  -- Default todo file location
            global_file = "~/notes/todo.md"  -- Same as target file for consistency
        })
    end,
}
