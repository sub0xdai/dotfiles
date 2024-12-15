return {
    -- This is a local plugin, no need for a URL
    dir = "",
    name = "sub0xterm",
    config = function()
        local M = {}

        local float_term_buf = nil
        local float_term_win = nil
        local last_terminal_cwd = nil

        function M.ToggleFloatingTerminal()
          -- Store current working directory if not already set
          if not last_terminal_cwd then
            last_terminal_cwd = vim.fn.getcwd()
          end

          -- If terminal is already open, close it
          if float_term_win and vim.api.nvim_win_is_valid(float_term_win) then
            vim.api.nvim_win_close(float_term_win, true)
            float_term_win = nil
            float_term_buf = nil
            return
          end

          -- Calculate window dimensions
          local width = vim.api.nvim_get_option("columns")
          local height = vim.api.nvim_get_option("lines")
          
          local win_width = math.floor(width * 0.8)
          local win_height = math.floor(height * 0.7)
          
          local row = math.floor((height - win_height) / 2)
          local col = math.floor((width - win_width) / 2)
          
          -- Create or reuse buffer
          if not float_term_buf or not vim.api.nvim_buf_is_valid(float_term_buf) then
            float_term_buf = vim.api.nvim_create_buf(false, true)
          end

          -- Open floating window
          float_term_win = vim.api.nvim_open_win(float_term_buf, true, {
            relative = 'editor',
            width = win_width,
            height = win_height,
            row = row,
            col = col,
            style = 'minimal',
            border = 'rounded'
          })

          -- Open terminal in the buffer if it's not already a terminal
          if vim.bo[float_term_buf].buftype ~= 'terminal' then
            -- Change to the last known working directory
            if last_terminal_cwd then
              vim.cmd('lcd ' .. last_terminal_cwd)
            end
            
            vim.cmd.term()
          end

          -- Set up Ctrl+Q to close the terminal
          vim.keymap.set('t', '<C-q>', function()
            -- Save the current working directory before closing
            last_terminal_cwd = vim.fn.getcwd()
            M.ToggleFloatingTerminal()
          end, { buffer = true })

          -- Automatically enter terminal mode
          vim.defer_fn(function()
            vim.cmd('startinsert')
          end, 50)
        end

        -- Export the function to be used in keymaps
        vim.api.nvim_create_user_command('ToggleFloatingTerminal', M.ToggleFloatingTerminal, {})
        
        -- You can add your keybinding here
        vim.keymap.set('n', '<leader>t', ':ToggleFloatingTerminal<CR>', { noremap = true, silent = true })

        -- Autocmd to disable line numbers and set local settings for terminal
        vim.api.nvim_create_autocmd('TermOpen', {
          group = vim.api.nvim_create_augroup('custom-term-open', { clear = true }),
          callback = function()
            vim.opt_local.number = false
            vim.opt_local.relativenumber = false
          end,
        })
    end,
}
