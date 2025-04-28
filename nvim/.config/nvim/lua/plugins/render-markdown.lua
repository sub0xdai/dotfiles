return {
    "MeanderingProgrammer/render-markdown.nvim",
    config = function()
        require('render-markdown').setup({
            -- Enable the plugin by default
            enabled = true,

            -- Specify file types to render
            file_types = { 'markdown', 'quarto' },

            -- Set render modes (normal and command mode)
            render_modes = { 'n', 'c' },

            -- Enable anti-conceal feature
            anti_conceal = { enabled = true },

            -- Set maximum file size to render (in MB)
            max_file_size = 10.0,

            -- Set debounce time for rendering (in milliseconds)
            debounce = 100,

            -- Use default window options
            win_options = {
                conceallevel = {
                    default = vim.api.nvim_get_option_value('conceallevel', {}),
                    rendered = 3,
                },
                concealcursor = {
                    default = vim.api.nvim_get_option_value('concealcursor', {}),
                    rendered = '',
                },
            },
        })
    end,
}




