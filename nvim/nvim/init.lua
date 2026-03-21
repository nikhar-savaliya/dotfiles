-- leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- sensible defaults
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.softtabstop = 2
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.confirm = true
vim.opt.termguicolors = true
vim.opt.winborder = "rounded"
vim.opt.smoothscroll = true

-- sync clipboard
vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)

-- basic keymaps
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic quickfix list" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus left" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus right" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus down" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus up" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down with centering" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up with centering" })

-- After basic keymaps section, before autocmds

-- jj to escape in insert mode
vim.keymap.set("i", "jj", "<Esc>")

-- Center screen on search
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")

-- Visual mode improvements
vim.keymap.set("v", ">", ">gv", { desc = "Indent and reselect" })
vim.keymap.set("v", "<", "<gv", { desc = "Outdent and reselect" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move lines down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move lines up" })

-- Paste without losing register
vim.keymap.set("x", "p", '"_dP')

-- Buffer management (matching VSCode space b)
vim.keymap.set("n", "<leader>bd", "<cmd>bd<CR>", { desc = "Delete buffer" })
vim.keymap.set("n", "<leader>bo", "<cmd>%bd|e#|bd#<CR>", { desc = "Delete other buffers" })


-- Tab/Shift-Tab for buffer navigation
vim.keymap.set("n", "<Tab>", "<cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })

-- highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd("CmdlineLeave", {
  pattern = "[/?]",
  callback = function()
    vim.schedule(function()
      vim.cmd.nohlsearch()
    end)
  end,
})

local function get_macos_appearance()
  local handle = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null")
  local result = handle:read("*a")
  handle:close()
  return result:match("Dark") and "dark" or "light"
end

-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error("Error cloning lazy.nvim:\n" .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- colorscheme
  {
    "webhooked/kanso.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      -- local appearance = get_macos_appearance()
      -- vim.opt.background = appearance
      --
      -- require("rose-pine").setup({
      --   variant = appearance == "dark" and "moon" or "dawn",
      -- })
      -- vim.cmd.colorscheme("rose-pine")
      vim.cmd.colorscheme("kanso")
    end,
  },

  -- detect indent
  { "NMAC427/guess-indent.nvim", opts = {} },

  -- telescope
  {
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make", cond = vim.fn.executable("make") == 1 },
      "nvim-telescope/telescope-ui-select.nvim",
    },
    config = function()
      local actions = require("telescope.actions")
      local telescope = require("telescope")
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
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
        },
      })
      pcall(telescope.load_extension, "fzf")
      pcall(telescope.load_extension, "ui-select")

      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader><leader>", builtin.git_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>lg", builtin.live_grep, { desc = "Live grep" })
      vim.keymap.set("n", "<leader>gs", builtin.grep_string, { desc = "Grep string" })
      vim.keymap.set("n", "<leader>ht", builtin.help_tags, { desc = "Help tags" })
      vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "Search keymaps" })
      vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "Search diagnostics" })
      vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "Search resume" })
      vim.keymap.set("n", "<leader>so", builtin.oldfiles, { desc = "Search Old files" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })

      -- Add these new ones
      vim.keymap.set("n", "<leader>sc", function()
        builtin.colorscheme({ enable_preview = true })
      end, { desc = "Search colorscheme" })
      vim.keymap.set("n", "<leader>sq", builtin.quickfix, { desc = "Search quickfix" })
      vim.keymap.set("n", "<leader>sm", builtin.marks, { desc = "Search marks" })
      vim.keymap.set("n", "<leader>sr", builtin.registers, { desc = "Search registers" })
      vim.keymap.set("n", "<leader>st", builtin.current_buffer_tags, { desc = "Search buffer tags" })
      vim.keymap.set("n", "<leader>sh", builtin.command_history, { desc = "Search command history" })
      vim.keymap.set("n", "<leader>sj", builtin.jumplist, { desc = "Search jumplist" })
      vim.keymap.set("n", "<leader>sa", builtin.autocommands, { desc = "Search autocommands" })
      vim.keymap.set("n", "<leader>ss", builtin.spell_suggest, { desc = "Spell suggest" })

      vim.keymap.set("n", "<leader>/", function()
        builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
          winblend = 10,
          previewer = false,
        }))
      end, { desc = "Fuzzy search buffer" })
    end,
  },

  -- oil.nvim
  {
    "stevearc/oil.nvim",
    lazy = false,
    config = function()
      require("oil").setup({
        default_file_explorer = true,
        columns = { "icon" },
        view_options = {
          show_hidden = true,
        },
        float = {
          padding = 2,
          max_width = 90,
          max_height = 30,
          border = "rounded",
          win_options = {
            winblend = 0,
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
      vim.keymap.set("n", "-", "<CMD>Oil --float<CR>", { desc = "Open parent directory" })
    end,
  },

  -- lsp
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "mason-org/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      { "j-hui/fidget.nvim", opts = {} },
      { "folke/lazydev.nvim", ft = "lua", opts = { library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } } } },
    },
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          map("gd", require("telescope.builtin").lsp_definitions, "Goto definition")
          map("gr", require("telescope.builtin").lsp_references, "Goto references")
          map("gI", require("telescope.builtin").lsp_implementations, "Goto implementation")
          map("gy", require("telescope.builtin").lsp_type_definitions, "Goto type definition")
          map("gD", vim.lsp.buf.declaration, "Goto declaration")
          map("<leader>cs", require("telescope.builtin").lsp_document_symbols, "Document symbols")
          map("<leader>cS", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Workspace symbols")
          map("<leader>cr", vim.lsp.buf.rename, "Rename")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "x" })
          map("K", vim.lsp.buf.hover, "Hover")

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map("<leader>th", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
            end, "Toggle inlay hints")
          end


        end,
      })

      vim.diagnostic.config({
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
        underline = { severity = vim.diagnostic.severity.ERROR },
        virtual_text = { source = "if_many", spacing = 2 },
      })



      local capabilities = require("blink.cmp").get_lsp_capabilities()

      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = "Replace" },
            },
          },
        },
        ts_ls = {},
      }

      local ensure_installed = vim.tbl_keys(servers)

      require("mason-tool-installer").setup({ ensure_installed = ensure_installed })
      require("mason-lspconfig").setup({
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
            require("lspconfig")[server_name].setup(server)
          end,
        },
      })
    end,
  },

  -- blink.cmp
  {
    "saghen/blink.cmp",
    event = "VimEnter",
    version = "1.*",
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      keymap = {
        preset = "none",
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide" },
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = { "accept", "fallback" },
        ["<C-j>"] = { "select_next", "fallback" },
        ["<C-k>"] = { "select_prev", "fallback" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
        ["<C-n>"] = { "snippet_forward", "fallback" },
        ["<C-p>"] = { "snippet_backward", "fallback" },
      },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        menu = {
          draw = {
            columns = { { "label", "label_description", gap = 1 } },
          },
        },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "lazydev" },
        providers = {
          lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
        },
      },
      signature = { enabled = true },
      fuzzy = { implementation = "prefer_rust" },
    },
  },

  -- treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({})
      local langs = {
        "bash", "c", "diff", "html", "css", "javascript", "typescript", "tsx",
        "json", "jsonc", "lua", "luadoc", "markdown", "markdown_inline",
        "python", "query", "regex", "vim", "vimdoc", "yaml", "toml", "rust", "go",
      }
      require("nvim-treesitter").install(langs)
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },

  -- treesitter textobjects
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "VeryLazy",
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local move = require("nvim-treesitter-textobjects.move")

      vim.keymap.set({ "x", "o" }, "af", function() select.select_textobject("@function.outer", "textobjects") end)
      vim.keymap.set({ "x", "o" }, "if", function() select.select_textobject("@function.inner", "textobjects") end)
      vim.keymap.set({ "x", "o" }, "ac", function() select.select_textobject("@class.outer", "textobjects") end)
      vim.keymap.set({ "x", "o" }, "ic", function() select.select_textobject("@class.inner", "textobjects") end)
      vim.keymap.set({ "x", "o" }, "aa", function() select.select_textobject("@parameter.outer", "textobjects") end)
      vim.keymap.set({ "x", "o" }, "ia", function() select.select_textobject("@parameter.inner", "textobjects") end)

      vim.keymap.set({ "n", "x", "o" }, "]f", function() move.goto_next_start("@function.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "[f", function() move.goto_previous_start("@function.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "]c", function() move.goto_next_start("@class.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "[c", function() move.goto_previous_start("@class.outer", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "]a", function() move.goto_next_start("@parameter.inner", "textobjects") end)
      vim.keymap.set({ "n", "x", "o" }, "[a", function() move.goto_previous_start("@parameter.inner", "textobjects") end)
    end,
  },

  -- comments
  { "numToStr/Comment.nvim", opts = {} },

  -- mini.nvim
  {
    "nvim-mini/mini.nvim",
    config = function()
      require("mini.icons").setup()
      MiniIcons.mock_nvim_web_devicons()  -- Make oil.nvim use mini.icons

      require("mini.ai").setup({ n_lines = 500 })
      require("mini.surround").setup()
      require("mini.pairs").setup()
      local statusline = require("mini.statusline")
      statusline.setup({
        use_icons = true,
        content = {
          active = function()
            local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
            local git = statusline.section_git({ trunc_width = 40 })
            local filename = statusline.section_filename({ trunc_width = 140 })

            return statusline.combine_groups({
              { hl = mode_hl, strings = { mode } },
              { hl = "MiniStatuslineDevinfo", strings = { git } },
              "%=",
              { hl = "MiniStatuslineFilename", strings = { filename } },
            })
          end,
          inactive = function()
            local filename = statusline.section_filename({ trunc_width = 140 })
            return statusline.combine_groups({
              "%=",
              { hl = "MiniStatuslineFilename", strings = { filename } },
            })
          end,
        },
      })
      -- require("mini.diff").setup({
        --   view = {
          --     style = "sign",
          --     signs = { add = "+", change = "~", delete = "_" },
          --   },
          -- })
          require("mini.git").setup()
        end,
      },

      -- Color hex codes
      {
        "NvChad/nvim-colorizer.lua",
        opts = {},
      },

      -- File tree (alternative to oil)
      {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
          "nvim-lua/plenary.nvim",
          "MunifTanjim/nui.nvim",
        },
        keys = {
          { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "File tree" },
        },
      },

      -- Better git signs & blame
      {
        "lewis6991/gitsigns.nvim",
        opts = {
          signs = {
            add = { text = "+" },
            change = { text = "~" },
            delete = { text = "_" },
          },
          current_line_blame = true,
        },
      },

      -- Git UI
      {
        "NeogitOrg/neogit",
        dependencies = "nvim-lua/plenary.nvim",
        opts = {},
        keys = {
          { "<leader>gg", "<cmd>Neogit<cr>", desc = "Neogit" },
        },
      },

      -- Auto-format on save
      {
        "stevearc/conform.nvim",
        opts = {
          formatters_by_ft = {
            lua = { "stylua" },
            javascript = { "prettier" },
            typescript = { "prettier" },
          },
          format_on_save = { timeout_ms = 500 },
        },
      },

      -- Better diagnostics list
      {
        "folke/trouble.nvim",
        opts = {},
        keys = {
          { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics" },
          { "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics" },
        },
      },

      {
        "goolord/alpha-nvim",
        config = function()
          local alpha = require("alpha")
          local dashboard = require("alpha.themes.dashboard")
          alpha.setup(dashboard.config)
        end,
      },

      {
        "goolord/alpha-nvim",
        config = function()
          local alpha = require("alpha")
          local dashboard = require("alpha.themes.dashboard")
          alpha.setup(dashboard.config)
        end,
      },

      -- Replace mini.diff with
      {
        "sindrets/diffview.nvim",
      },

      -- Add to mini.nvim or separate
      {
        "utilyre/barbecue.nvim",
        dependencies = {
          "SmiteshP/nvim-navic",
        },
        opts = {},
      },

      -- flash.nvim
      {
        "folke/flash.nvim",
        event = "VeryLazy",
        opts = {
          labels = "asdfghjklqwertyuiopzxcvbnm",
          search = { mode = "fuzzy" },
          jump = { autojump = true },
          label = { uppercase = false },
          prompt = { prefix = { { "> " } } },
          modes = {
            char = { enabled = false },
            search = { enabled = false },
          },
        },
        keys = {
          { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
          { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
        },
      },

    }, {
      ui = {
        icons = {
          cmd = "",
          config = "",
          event = "",
          ft = "",
          init = "",
          keys = "",
          plugin = "",
          runtime = "",
          require = "",
          source = "",
          start = "",
          task = "",
          lazy = "",
        },
      },
    })

    -- -- Add global LSP border config here
    -- vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
      --   vim.lsp.handlers.hover, { border = "rounded" }
      -- )
      -- vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
        --   vim.lsp.handlers.signature_help, { border = "rounded" }
        -- )
