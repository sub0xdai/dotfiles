local utils = require("utils")

local M = {}

--- Creates a configuration for the floating window
--- @return table Configuration for the floating window
local function float_win_config()
    local width = math.min(math.floor(vim.o.columns * 0.8), 64)
    local height = math.floor(vim.o.lines * 0.8)

    return {
        relative = "editor",
        width = width,
        height = height,
        col = utils.center_in(vim.o.columns, width),
        row = utils.center_in(vim.o.lines, height),
        border = "single",
    }
end

--- Sets up mappings for todo items in the given buffer
--- @param buf number Buffer ID
local function setup_todo_mappings(buf)
    -- Toggle checkbox state
    vim.keymap.set("n", "<space>", function()
        local line = vim.api.nvim_get_current_line()
        local new_line = line:gsub("^(%s*[-*] )%[([x ])%]", function(prefix, check)
            return prefix .. "[" .. (check == " " and "x" or " ") .. "]"
        end)
        vim.api.nvim_set_current_line(new_line)
    end, { buffer = buf, silent = true })

    -- Create new todo item
    vim.keymap.set("n", "o", function()
        local line = vim.api.nvim_get_current_line()
        local indent = line:match("^%s*")
        vim.api.nvim_put({ indent .. "- [ ] " }, "l", true, true)
    end, { buffer = buf, silent = true })

    -- Create new todo item above
    vim.keymap.set("n", "O", function()
        local line = vim.api.nvim_get_current_line()
        local indent = line:match("^%s*")
        vim.api.nvim_put({ indent .. "- [ ] " }, "l", false, true)
    end, { buffer = buf, silent = true })

    -- Set filetype to markdown
    vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
end

--- Opens a file in a floating window
--- @param filepath string The path to the file to open
--- @return number|nil The buffer ID if successful, nil otherwise
local function open_floating_file(filepath)
    local path = utils.expand_path(filepath)

    -- Look for an existing buffer with this file
    local buf = vim.fn.bufnr(path, true)

    -- If the buffer doesn't exist, create one and edit the file
    if buf == -1 then
        buf = vim.api.nvim_create_buf(false, false)
        vim.api.nvim_buf_set_name(buf, path)
        vim.api.nvim_buf_call(buf, function()
            vim.cmd("edit " .. vim.fn.fnameescape(path))
        end)
    end

    local win = vim.api.nvim_open_win(buf, true, float_win_config())
    vim.cmd("setlocal nospell")

    vim.api.nvim_buf_set_keymap(buf, "n", "q", "", {
        noremap = true,
        silent = true,
        callback = function()
            -- Check if the buffer has unsaved changes
            if vim.api.nvim_get_option_value("modified", { buf = buf }) then
                vim.ui.select(
                    { "Save", "Discard", "Cancel" },
                    { prompt = "File has unsaved changes:" },
                    function(choice)
                        if choice == "Save" then
                            vim.cmd("write")
                            vim.api.nvim_win_close(0, true)
                        elseif choice == "Discard" then
                            vim.api.nvim_win_close(0, true)
                        end
                        -- Cancel does nothing
                    end
                )
            else
                vim.api.nvim_win_close(0, true)
            end
        end,
    })

    vim.api.nvim_create_autocmd("VimResized", {
        callback = function()
            vim.api.nvim_win_set_config(win, float_win_config())
        end,
        once = false,
    })

    return buf
end

--- Opens or creates an ideas file in a floating window
--- @param filepath string The path to the ideas file
--- @return number|nil The buffer ID if successful, nil otherwise
local function open_ideas_file(filepath)
    local path = utils.expand_path(filepath)
    if vim.fn.filereadable(path) == 0 then
        local file, err = io.open(path, "w")
        if not file then
            vim.notify("Could not create file: " .. path .. " (" .. err .. ")", vim.log.levels.ERROR)
            return
        end
        file:write("# Ideas\n\n## New Ideas\n\n")
        file:close()
    end
    return open_floating_file(path)
end

--- Opens or creates a todo file in a floating window
--- @param filepath string The path to the todo file
--- @return number|nil The buffer ID if successful, nil otherwise
local function open_todo_file(filepath)
    local path = utils.expand_path(filepath)
    if vim.fn.filereadable(path) == 0 then
        local file, err = io.open(path, "w")
        if not file then
            vim.notify("Could not create file: " .. path .. " (" .. err .. ")", vim.log.levels.ERROR)
            return
        end
        file:write("# Todo List\n\n- [ ] First todo item\n")
        file:close()
    end
    local buf = open_floating_file(path)
    if buf then
        setup_todo_mappings(buf)
    end
    return buf
end

--- Sets up user commands based on the provided options
--- @param opts table Configuration options
local function setup_user_commands(opts)
    local todo_file = opts.todo_file or "todo.md"
    local resolved_todo_file = vim.fn.resolve(todo_file)

    if vim.fn.filereadable(resolved_todo_file) == 1 then
        opts.todo_file = resolved_todo_file
    else
        opts.todo_file = opts.global_file
    end

    vim.api.nvim_create_user_command("Td", function()
        open_todo_file(opts.todo_file)
    end, {})
    
    vim.api.nvim_create_user_command("Ti", function()
        open_ideas_file(opts.ideas_file or "~/notes/ideas.md")
    end, {})
end

--- Sets up keymaps based on the provided options
--- @param opts table Configuration options
local function setup_keymaps(opts)
    local keymap_opts = { silent = true }
    vim.keymap.set("n", opts.keys.todo or "<leader>td", ":Td<CR>", keymap_opts)
    vim.keymap.set("n", opts.keys.ideas or "<leader>ti", ":Ti<CR>", keymap_opts)
end

--- Sets up the plugin with the provided options
--- @param opts table|nil Configuration options
M.setup = function(opts)
    opts = opts or {}
    opts.keys = opts.keys or {}
    
    setup_user_commands(opts)
    
    if opts.setup_keymaps ~= false then
        setup_keymaps(opts)
    end
end

return M
