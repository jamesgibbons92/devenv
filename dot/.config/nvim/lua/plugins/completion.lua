return {
  -- {
  --   "zbirenbaum/copilot.lua",
  --   cmd = "Copilot",
  --   event = "InsertEnter",
  --   opts = {
  --     suggestion = { enabled = false },
  --     panel = { enabled = false },
  --     filetypes = {
  --       typescript = true,
  --       ts = true,
  --     },
  --   },
  -- },
  { -- Autocompletion
    "saghen/blink.cmp",
    event = "VimEnter",
    version = "1.*",
    dependencies = {
      -- Snippet Engine
      {
        "L3MON4D3/LuaSnip",
        version = "2.*",
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
            return
          end
          return "make install_jsregexp"
        end)(),
        dependencies = {
          -- `friendly-snippets` contains a variety of premade snippets.
          --    See the README about individual language/framework/plugin snippets:
          --    https://github.com/rafamadriz/friendly-snippets
          -- {
          --   'rafamadriz/friendly-snippets',
          --   config = function()
          --     require('luasnip.loaders.from_vscode').lazy_load()
          --   end,
          -- },
        },
        opts = {},
      },
      "folke/lazydev.nvim",
      "fang2hou/blink-copilot",
    },
    --- @module 'blink.cmp'
    --- @type blink.cmp.Config
    opts = {
      keymap = {
        -- 'default' (recommended) for mappings similar to built-in completions
        --   <c-y> to accept ([y]es) the completion.
        --    This will auto-import if your LSP supports it.
        --    This will expand snippets if the LSP sent a snippet.
        -- 'super-tab' for tab to accept
        -- 'enter' for enter to accept
        -- 'none' for no mappings
        --
        -- For an understanding of why the 'default' preset is recommended,
        -- you will need to read `:help ins-completion`
        --
        -- No, but seriously. Please read `:help ins-completion`, it is really good!
        --
        -- All presets have the following mappings:
        -- <tab>/<s-tab>: move to right/left of your snippet expansion
        -- <c-space>: Open menu or open docs if already open
        -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
        -- <c-e>: Hide menu
        -- <c-k>: Toggle signature help
        --
        -- See :h blink-cmp-config-keymap for defining your own keymap
        preset = "enter",

        -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
        --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
      },

      appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = "mono",
      },

      completion = {
        list = { selection = { preselect = false, auto_insert = false } },
        -- By default, you may press `<c-space>` to show the documentation.
        -- Optionally, set `auto_show = true` to show the documentation after a delay.
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        ghost_text = { enabled = false },
      },

      sources = {
        -- default = { "lsp", "path", "snippets", "lazydev" },
        default = { "copilot", "lsp", "path", "snippets", "lazydev" },
        -- default = { "copilot", "lsp" },
        providers = {
          lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
          copilot = { -- Changed '//' to '--' for Lua comment
            name = "copilot",
            module = "blink-copilot",
            score_offset = 100,
            async = true,
            enabled = function()
              if string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), "^%.env.*") then
                -- disable for .env files
                return false
              end
              return true
            end,
            opts = {
              debounce = 100,
            },
          },
        },
      },

      snippets = { preset = "luasnip" },

      -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
      -- which automatically downloads a prebuilt binary when enabled.
      --
      -- By default, we use the Lua implementation instead, but you may enable
      -- the rust implementation via `'prefer_rust_with_warning'`
      --
      -- See :h blink-cmp-config-fuzzy for more information
      fuzzy = { implementation = "lua" },

      -- Shows a signature help window while you type arguments for a function
      signature = { enabled = true },
    },
  },
  {
    "copilotlsp-nvim/copilot-lsp",
    init = function()
      vim.g.copilot_nes_debounce = 500

      local function safely_detach_copilot(bufnr)
        local clients = vim.lsp.get_clients({ name = "copilot_ls", bufnr = bufnr })
        for _, client in pairs(clients) do
          vim.lsp.buf_detach_client(bufnr, client.id)
        end
      end
      vim.lsp.enable("copilot_ls")

      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = { ".env", ".env.*" },
        callback = function()
          local bufnr = vim.api.nvim_get_current_buf()
          vim.schedule(function()
            safely_detach_copilot(bufnr)
          end)
        end,
      })

      local function handle_tab()
        return require("copilot-lsp.nes").walk_cursor_start_edit()
          or (require("copilot-lsp.nes").apply_pending_nes() and require("copilot-lsp.nes").walk_cursor_end_edit())
      end
      vim.keymap.set("n", "<tab>", function()
        if not handle_tab() then
        end
      end)
      vim.keymap.set("i", "<tab>", function()
        if not handle_tab() then
          vim.api.nvim_feedkeys("\t", "n", true)
        end
      end)

      -- Clear copilot suggestion with Esc if visible, otherwise preserve default Esc behavior
      vim.keymap.set("n", "<esc>", function()
        if not require("copilot-lsp.nes").clear() then
          -- fallback to other functionality
        end
      end, { desc = "Clear Copilot suggestion or fallback" })
    end,
  },
}
