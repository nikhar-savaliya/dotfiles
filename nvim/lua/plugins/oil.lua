
return {
  "stevearc/oil.nvim",
  lazy = false,
  dependencies = { "nvim-mini/mini.icons" },
  config = function()
    require("oil").setup({
      default_file_explorer = true,
      columns = { "icon" },
      view_options = {
        show_hidden = true,
      },
      -- This section controls the floating window appearance
      float = {
        padding = 2,
        max_width = 80,
        max_height = 20,
        border = "rounded",
        win_options = {
          winblend = 0, -- Set to 10-20 if you want a subtle transparent look
        },
      },
      keymaps = {
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        ["<C-v>"] = "actions.select_vsplit",
        ["<C-s>"] = "actions.select_split",
        ["<C-t>"] = "actions.select_tab",
        ["<C-p>"] = "actions.preview",
        ["<Esc>"] = "actions.close",
        ["<C-r>"] = "actions.refresh",
        ["-"] = "actions.parent",
        ["_"] = "actions.open_cwd",
        ["`"] = "actions.cd",
        ["~"] = "actions.tcd",
        ["gs"] = "actions.change_sort",
        ["gx"] = "actions.open_external",
        ["g."] = "actions.toggle_hidden",
      },
    })

    -- Set the global keymap
    vim.keymap.set("n", "-", function() require("oil").open_float() end, { desc = "Open oil in float" })
  end,
}