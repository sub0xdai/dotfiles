-- sub0xterm plugin
local api = vim.api
local fn = vim.fn

-- Default options
local opts = {
    toggle_key = '<A-t>',
    close_key = '<C-q>',
    border = 'rounded',
}

-- Plugin state
local float_term_buf = nil
local float_term_win = nil

-- Get directory of current buffer or oil.nvim
local function get_current_directory()
    local current_buf = api.nvim_get_current_buf()
    local file_type = vim.bo[current_buf].filetype
    
    if file_type == "oil" then
        return vim.b[current_buf].oil_dir
    else
        local file_path = fn.expand('%:p:h')
        return file_path ~= "" and file_path or fn.getcwd()
    end
end

-- Create or show floating terminal
local function create_or_show_float_term()
    if float_term_buf and api.nvim_buf_is_valid(float_term_buf) and
       float_term_win and api.nvim_win_is_valid(float_term_win) then
        api.nvim_set_current_win(float_term_win)
        return
    end

    -- Get window dimensions
    local width = api.nvim_get_option("columns")
    local height = api.nvim_get_option("lines")

    -- Calculate floating window size
    local win_height = math.ceil(height * 0.8)
    local win_width = math.ceil(width * 0.8)

    -- Calculate starting position
    local row = math.ceil((height - win_height) / 2)
    local col = math.ceil((width - win_width) / 2)

    -- Create buffer for terminal
    float_term_buf = api.nvim_create_buf(false, true)

    -- Set up window options
    local win_opts = {
        relative = 'editor',
        width = win_width,
        height = win_height,
        row = row,
        col = col,
        style = 'minimal',
        border = opts.border
    }

    -- Create window
    float_term_win = api.nvim_open_win(float_term_buf, true, win_opts)

    -- Get current directory
    local current_dir = get_current_directory()

    -- Start terminal in buffer
    fn.termopen(vim.o.shell, {
        cwd = current_dir,
        on_exit = function()
            if api.nvim_win_is_valid(float_term_win) then
                api.nvim_win_close(float_term_win, true)
            end
            float_term_win = nil
            float_term_buf = nil
        end
    })

    -- Enter insert mode
    vim.cmd('startinsert')
end

-- Close floating terminal
local function close_float_term()
    if float_term_win and api.nvim_win_is_valid(float_term_win) then
        api.nvim_win_close(float_term_win, true)
        float_term_win = nil
        float_term_buf = nil
    end
end

-- Set up keymaps
vim.keymap.set('n', opts.toggle_key, create_or_show_float_term, { noremap = true, silent = true })
vim.keymap.set('t', opts.toggle_key, function()
    vim.cmd([[stopinsert]])
    close_float_term()
end, { noremap = true, silent = true })
vim.keymap.set('t', opts.close_key, function()
    vim.cmd([[stopinsert]])
    close_float_term()
end, { noremap = true, silent = true })
