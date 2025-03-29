local utils = require("utils")

local M = {}

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
				vim.notify("save your changes bro", vim.log.levels.WARN)
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

local function open_ideas_file(filepath)
    local path = utils.expand_path(filepath)
    if vim.fn.filereadable(path) == 0 then
        local file = io.open(path, "w")
        if file then
            file:write("# Ideas\n\n## New Ideas\n\n")
            file:close()
        else
            vim.notify("Could not create file: " .. path, vim.log.levels.ERROR)
            return
        end
    end
    open_floating_file(path)
end

local function open_todo_file(filepath)
    local path = utils.expand_path(filepath)
    if vim.fn.filereadable(path) == 0 then
        local file = io.open(path, "w")
        if file then
            file:write("# Todo List\n\n- [ ] First todo item\n")
            file:close()
        else
            vim.notify("Could not create file: " .. path, vim.log.levels.ERROR)
            return
        end
    end
    local buf = open_floating_file(path)
    if buf then
        setup_todo_mappings(buf)
    end
end

local function setup_user_commands(opts)
	local target_file = opts.target_file or "todo.md"
	local resolved_target_file = vim.fn.resolve(target_file)

	if vim.fn.filereadable(resolved_target_file) == true then
		opts.target_file = resolved_target_file
	else
		opts.target_file = opts.global_file
	end

	vim.api.nvim_create_user_command("Td", function()
		open_todo_file(opts.target_file)
	end, {})
	vim.api.nvim_create_user_command("Ti", function()
		open_ideas_file("~/notes/ideas.md")
	end, {})
end

local function setup_keymaps()
	vim.keymap.set("n", "<leader>td", ":Td<CR>", { silent = true })
	vim.keymap.set("n", "<leader>ti", ":Ti<CR>", { silent = true })
end

M.setup = function(opts)
	setup_user_commands(opts)
	setup_keymaps()
end

return M
