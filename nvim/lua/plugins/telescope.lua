return {
  {
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make", cond = vim.fn.executable("make") == 1 },
      "nvim-telescope/telescope-ui-select.nvim",
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          file_ignore_patterns = { "node_modules", ".git/" },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
            },
            n = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
            },
          },
        },
        extensions = {
          ["ui-select"] = require("telescope.themes").get_dropdown(),
        },
      })

      pcall(telescope.load_extension, "fzf")
      pcall(telescope.load_extension, "ui-select")

      -- keymaps
      local b = require("telescope.builtin")
      local map = vim.keymap.set

      map("n", "<leader>ff", b.find_files, { desc = "Files" })
      map("n", "<leader>fg", b.live_grep, { desc = "Grep" })
      map("n", "<leader>fw", b.grep_string, { desc = "Word" })
      map("n", "<leader>fb", b.buffers, { desc = "Buffers" })
      map("n", "<leader>fh", b.help_tags, { desc = "Help" })
      map("n", "<leader>fd", b.diagnostics, { desc = "Diagnostics" })
      map("n", "<leader>fr", b.resume, { desc = "Resume" })

      map("n", "<leader>/", function()
        b.current_buffer_fuzzy_find(
          require("telescope.themes").get_dropdown({
            previewer = false,
            winblend = 10,
          })
        )
      end, { desc = "Buffer search" })
    end,
  },
}
