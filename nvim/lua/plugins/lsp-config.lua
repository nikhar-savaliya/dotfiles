return {
  "neovim/nvim-lspconfig",
  dependencies = {
    { "williamboman/mason.nvim", opts = {} },
    "williamboman/mason-lspconfig.nvim",
  },
  config = function()
    -- Keymaps on LSP attach
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(event)
        local map = function(keys, func)
          vim.keymap.set("n", keys, func, { buffer = event.buf })
        end
        
        map("gd", vim.lsp.buf.definition)
        map("gr", vim.lsp.buf.references)
        map("K", vim.lsp.buf.hover)
        map("<leader>ca", vim.lsp.buf.code_action)
        map("<leader>rn", vim.lsp.buf.rename)
        map("<leader>gf", vim.lsp.buf.format)
      end,
    })

    -- Diagnostic config
    vim.diagnostic.config({
      virtual_text = { spacing = 2 },
      severity_sort = true,
      float = { border = "rounded" },
    })

    -- Get completion capabilities
    local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
    local capabilities = ok and cmp_nvim_lsp.default_capabilities() or vim.lsp.protocol.make_client_capabilities()

    -- Servers to install & configure
    local servers = { "lua_ls", "ts_ls", "tailwindcss", "ruby_lsp" }

    require("mason-lspconfig").setup({
      ensure_installed = servers,
      handlers = {
        function(server_name)
          require("lspconfig")[server_name].setup({
            capabilities = capabilities,
          })
        end,
      },
    })
  end,
}