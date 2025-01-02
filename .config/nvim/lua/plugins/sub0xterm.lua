return {
    dir = "/home/sub0x/dotfiles/.local/share/nvim/site/pack/local/start/sub0xterm",
    name = "sub0xterm",
    config = function()
        -- Cache frequently used API calls
        local api = vim.api
        local fn = vim.fn

        -- Cache options in local variables
        local opts = {
            toggle_key = '<A-t>',
            close_key = '<C-q>',
            border = 'rounded',
        }

        -- Use local variables for better performance
        local M = {}
        local float_term_buf = nil
        local float_term_win = nil

        -- Get directory of current buffer or oil.nvim
        local function get_current_buffer_directory()
            local current_buf = api.nvim_get_current_buf()
            local ft = vim.bo[current_buf].filetype

            -- Handle oil.nvim directory
            if ft == "oil" then
                -- Get the current oil directory
                return vim.fn.getcwd()
            end

            -- Get directory of current file
            local current_file = api.nvim_buf_get_name(current_buf)
            if current_file and current_file ~= "" then
                return vim.fn.fnamemodify(current_file, ":p:h")
            end

            -- Fallback to current working directory
            return vim.fn.getcwd()
        end

        -- Pre-calculate window dimensions
        local function calculate_window_dimensions()
            local width = api.nvim_get_option("columns")
            local height = api.nvim_get_option("lines")

            return {
                width = math.floor(width * 0.8),
                height = math.floor(height * 0.7),
                row = math.floor((height - math.floor(height * 0.7)) / 2),
                col = math.floor((width - math.floor(width * 0.8)) / 2)
            }
        end

        function M.ToggleFloatingTerminal()
            -- Close existing terminal
            if float_term_win and api.nvim_win_is_valid(float_term_win) then
                api.nvim_win_close(float_term_win, true)
                float_term_win = nil
                float_term_buf = nil
                return
            end

            -- Get the directory before creating terminal
            local cwd = get_current_buffer_directory()

            -- Create new buffer
            float_term_buf = api.nvim_create_buf(false, true)

            -- Set buffer options
            vim.bo[float_term_buf].buflisted = false
            vim.bo[float_term_buf].modifiable = true

            -- Calculate window dimensions
            local dims = calculate_window_dimensions()

            -- Set up window options
            local win_opts = {
                relative = 'editor',
                width = dims.width,
                height = dims.height,
                row = dims.row,
                col = dims.col,
                style = 'minimal',
                border = opts.border
            }

            -- Create window
            float_term_win = api.nvim_open_win(float_term_buf, true, win_opts)

            -- Set window options
            api.nvim_win_set_option(float_term_win, 'winhl', 'Normal:Normal,FloatBorder:FloatBorder')

            -- Start terminal in the correct directory
            vim.fn.termopen(vim.o.shell, {
                cwd = cwd,
                on_exit = function()
                    if float_term_win and api.nvim_win_is_valid(float_term_win) then
                        api.nvim_win_close(float_term_win, true)
                    end
                    float_term_win = nil
                    float_term_buf = nil
                end
            })

            -- Set up terminal mode mapping
            vim.keymap.set('t', opts.close_key, function()
                if float_term_win and api.nvim_win_is_valid(float_term_win) then
                    api.nvim_win_close(float_term_win, true)
                    float_term_win = nil
                    float_term_buf = nil
                end
            end, { buffer = float_term_buf, noremap = true, silent = true })

            -- Enter terminal mode
            vim.cmd('startinsert')
        end

        -- Create command and keymap
        api.nvim_create_user_command('ToggleFloatingTerminal', M.ToggleFloatingTerminal, {})
        vim.keymap.set('n', opts.toggle_key, M.ToggleFloatingTerminal,
            { noremap = true, silent = true })

        -- Set up terminal options
        local group = api.nvim_create_augroup('terminal_settings', { clear = true })
        api.nvim_create_autocmd('TermOpen', {
            group = group,
            callback = function()
                vim.wo.number = false
                vim.wo.relativenumber = false
                vim.wo.signcolumn = 'no'
            end,
        })
    end,
}
