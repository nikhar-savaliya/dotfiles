-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.conceallevel = 0 -- show raw markdown syntax instead of inline rendering
vim.opt.smoothscroll = false
vim.opt.spell = false
vim.g.snacks_animate = false

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "SnacksIndent", { fg = "#262628" })
    vim.api.nvim_set_hl(0, "SnacksIndentScope", { fg = "#313134" })
    vim.api.nvim_set_hl(0, "SnacksDiffContext", { link = "Normal" })
    vim.api.nvim_set_hl(0, "SnacksDiffContextLineNr", { fg = "#6c6874" })
    -- Readable git diff: dark tint + main text fg (syntax colors were unreadable on tinted bg)
    vim.api.nvim_set_hl(0, "DiffAdd", { bg = "#1a2e22", fg = "#c9c7cd" })
    vim.api.nvim_set_hl(0, "DiffDelete", { bg = "#2e1a22", fg = "#c9c7cd" })
    vim.api.nvim_set_hl(0, "DiffChange", { link = "Normal" })
    vim.api.nvim_set_hl(0, "SnacksDiffAdd", { bg = "#1a2e22", fg = "#c9c7cd" })
    vim.api.nvim_set_hl(0, "SnacksDiffDelete", { bg = "#2e1a22", fg = "#c9c7cd" })
    vim.api.nvim_set_hl(0, "SnacksDiffAddLineNr", { bg = "#1a2e22", fg = "#6c6874" })
    vim.api.nvim_set_hl(0, "SnacksDiffDeleteLineNr", { bg = "#2e1a22", fg = "#6c6874" })
  end,
})
