return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
  },
  {
    "dgox16/oldworld.nvim",
    name = "oldworld",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("oldworld")
    end,
  },
  {
    "mellow-theme/mellow.nvim",
    name = "mellow",
  },
}
