return {
  "wincent/shannon",
  cmd = { "Shannon", "ShannonNextMark", "ShannonPreviousMark", "ShannonClearMarks" },
  keys = {
    { "<leader>ss", mode = { "n", "v" }, desc = "Shannon prompt" },
    { "<leader>sn", desc = "Shannon next mark" },
    { "<leader>sp", desc = "Shannon previous mark" },
    { "<leader>sc", desc = "Shannon clear marks" },
  },
  opts = {
    agents = { "claude", "pi" },
  },
  main = "wincent.shannon",
}
