return {
	"goolord/alpha-nvim",
	dependencies = {
		"echasnovski/mini.icons",
	},

	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")
    local logo = [[


                                      \
                                  `\,/
                                  .-'-.
                                 '     `
                                 `.   .'
                          `._  .-~     ~-.   _,'
                           ( )'           '.( )
             `._    _       /               .'
              ( )--' `-.  .'                 ;
         .    .'        '.;                  ()
          `.-.`           '                 .'
----*-----;                                .'
          .`-'.           ,                `.
         '    '.        .';                  ()
              (_)-   .-'  `.                 ;
             ,'   `-'       \               `.
                           (_).           .'(_)
                          .'   '-._   _.-'    `.
                                 .'   `.
                                 '     ;              ^sub0x_
                                  `-,-'
                                   /`\
                                 /`
 
    ]]

		dashboard.section.header.val = vim.split(logo, "\n")

		dashboard.section.buttons.val = {
			-- dashboard.button("e", "  > New file", ":ene <BAR> startinsert <CR>"),
			dashboard.button("b", "  > Browse files", function() require("mini.files").open() end),
			dashboard.button("z", "  > Browse Directories", function() Snacks.picker.zoxide() end),
			dashboard.button("f", "󰈞  > Find file", function() Snacks.picker.files({ hidden = true }) end),
			dashboard.button("r", "  > Recent", function() Snacks.picker.recent() end),
		}

		alpha.setup(dashboard.opts)
	end,
}
