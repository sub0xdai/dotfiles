return {
	"sindrets/diffview.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory" },
	keys = {
		{ "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview: Open" },
		{ "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: File History" },
		{ "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview: Branch History" },
		{ "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Diffview: Close" },
	},
	opts = {
		enhanced_diff_hl = true,
		view = {
			default = {
				layout = "diff2_horizontal",
			},
			merge_tool = {
				layout = "diff3_mixed",
				disable_diagnostics = true,
			},
		},
		file_panel = {
			win_config = {
				position = "left",
				width = 35,
			},
		},
		keymaps = {
			view = {
				["<tab>"] = function() require("diffview.actions").select_next_entry() end,
				["<s-tab>"] = function() require("diffview.actions").select_prev_entry() end,
				["gf"] = function() require("diffview.actions").goto_file_edit() end,
				["<leader>e"] = function() require("diffview.actions").toggle_files() end,
			},
			file_panel = {
				["j"] = function() require("diffview.actions").next_entry() end,
				["k"] = function() require("diffview.actions").prev_entry() end,
				["<cr>"] = function() require("diffview.actions").select_entry() end,
				["s"] = function() require("diffview.actions").toggle_stage_entry() end,
				["S"] = function() require("diffview.actions").stage_all() end,
				["U"] = function() require("diffview.actions").unstage_all() end,
				["X"] = function() require("diffview.actions").restore_entry() end,
				["R"] = function() require("diffview.actions").refresh_files() end,
				["<leader>e"] = function() require("diffview.actions").toggle_files() end,
			},
		},
	},
}
