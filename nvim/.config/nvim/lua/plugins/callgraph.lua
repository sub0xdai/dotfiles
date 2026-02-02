return {
	"barreiroleo/callgraph.nvim",
	opts = {
		run = {
			direction = "in",
			depth_limit_in = 10,
			depth_limit_out = 6,
			filter_location = {},
			invert_filter = false,
		},
		export = {
			file_path = "/tmp/callgraph.dot",
			graph_name = "CallGraph",
			direction = "LR",
		},
	},
	keys = {
		{ "<leader>cgi", function() require("callgraph").run({ direction = "in" }) end, desc = "Callgraph: incoming calls" },
		{ "<leader>cgo", function() require("callgraph").run({ direction = "out" }) end, desc = "Callgraph: outgoing calls" },
		{ "<leader>cgm", function() require("callgraph").run({ direction = "mix" }) end, desc = "Callgraph: mixed calls" },
		{ "<leader>cga", function() require("callgraph").add_location() end, desc = "Callgraph: add location" },
	},
}
