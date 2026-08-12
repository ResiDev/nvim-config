-- ~/.config/nvim/lua/plugins/lsp.lua
return {
  {
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
  },

  { 'Bilal2453/luvit-meta', lazy = true },
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      { 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },
      -- Allows extra capabilities provided by nvim-cmp
      'saghen/blink.cmp',
      -- 'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      vim.lsp.document_color.enable(false)

      -- LSP provides Neovim with features like:
      --  - Go to definition
      --  - Find references
      --  - Autocompletion
      --  - Symbol Search

      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          -- We create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          -- map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          -- map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          -- map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          -- map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
          -- map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          -- map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>o', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          -- if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
          --   map('<leader>th', function()
          --     vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
          --   end, '[T]oggle Inlay [H]ints')
          -- end
        end,
      })

      --  NOTE: replaced by blink cmp
      -- local capabilities = vim.lsp.protocol.make_client_capabilities()
      -- capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
      local capabilities = require('blink.cmp').get_lsp_capabilities()
      capabilities.offsetEncoding = { 'utf-16' }
      capabilities.general = capabilities.general or {}
      capabilities.general.positionEncodings = { 'utf-16' }

      local js_filetypes = {
        'javascript',
        'javascriptreact',
        'typescript',
        'typescriptreact',
      }

      -- Pin every server to UTF-16 so multiple clients on the same buffer agree
      -- on position encoding. Otherwise tsgo negotiates UTF-8 while oxlint /
      -- tailwindcss use UTF-16, which misaligns diagnostics/hover/edits on lines
      -- containing multi-byte characters (see `:checkhealth vim.lsp`).
      --
      -- This must be a wildcard config: oxlint/tsgo/tailwindcss come from
      -- nvim-lspconfig's bundled `lsp/*.lua` files (not the mason handler below),
      -- so merging into `capabilities` alone would miss them. `vim.lsp.config('*')`
      -- deep-merges into every server regardless of how it is registered.
      vim.lsp.config('*', {
        capabilities = {
          general = { positionEncodings = { 'utf-16' } },
        },
      })

      -- nvim-lspconfig's bundled tailwindcss config force-enables
      -- didChangeWatchedFiles.dynamicRegistration, which Neovim deliberately
      -- ships disabled on Linux: registering watchers makes vim._watch walk the
      -- ENTIRE workspace (node_modules, .pnpm-store, ...) synchronously on the
      -- main thread — multi-second UI freezes on every attach in big repos.
      -- Trade-off: tailwind won't auto-detect tailwind.config edits; run
      -- `:LspRestart` after changing it.
      vim.lsp.config('tailwindcss', {
        capabilities = {
          workspace = { didChangeWatchedFiles = { dynamicRegistration = false } },
        },
      })

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      --

      local servers = {
        -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
        --
        -- Some languages (like typescript) have entire language plugins that can be useful:
        --    https://github.com/pmizio/typescript-tools.nvim

        tsgo = {
          cmd = { 'tsgo', '--lsp', '--stdio' },
          filetypes = js_filetypes,
          root_markers = {
            'tsconfig.json',
            'jsconfig.json',
            'package.json',
            '.git',
          },
          -- tsgo truncates hover text at 500 chars by default, which cuts off
          -- any non-trivial inferred type. It's exposed only as a raw/"unstable"
          -- preference (no stable settings path), read off initializationOptions
          -- and from the `unstable` block of the config sections it pulls — so
          -- set both, since a workspace/configuration refresh re-parses the latter.
          init_options = {
            maximumHoverLength = 10000,
          },
          settings = {
            typescript = {
              unstable = {
                maximumHoverLength = 10000,
              },
            },
          },
        },

        tailwindcss = {
          filetypes = {
            'astro',
            'html',
            'css',
            'less',
            'sass',
            'scss',
            'javascript',
            'javascriptreact',
            'typescript',
            'typescriptreact',
            'vue',
            'svelte',
          },
          settings = {
            tailwindCSS = {
              colorDecorators = 'off',
            },
          },
          on_attach = function(client)
            client.server_capabilities.colorProvider = nil
          end,
        },

        lua_ls = {
          -- cmd = {...},
          -- filetypes = { ...},
          -- capabilities = {},
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
      }

      -- Increase Node heap limit for LSP servers that OOM on large projects
      vim.env.NODE_OPTIONS = '--max-old-space-size=4096'

      require('mason').setup()

      vim.lsp.config.mojo = {
        capabilities = capabilities,
        cmd = { 'uv', 'run', vim.fn.getcwd() .. '/.venv/bin/mojo-lsp-server' },
      }
      vim.lsp.enable('mojo')

      vim.lsp.config.oxlint = {
        capabilities = capabilities,
        cmd = { 'oxlint', '--lsp' },
        filetypes = js_filetypes,
        root_markers = {
          '.oxlintrc.json',
          '.oxlintrc.jsonc',
          'oxlint.config.ts',
          'package.json',
          '.git',
        },
      }
      vim.lsp.enable('oxlint')

      vim.lsp.config.tsgo = vim.tbl_deep_extend('force', vim.lsp.config.tsgo or {}, servers.tsgo, {
        capabilities = capabilities,
      })
      vim.lsp.enable('tsgo')

      vim.lsp.config.tailwindcss = vim.tbl_deep_extend('force', vim.lsp.config.tailwindcss or {}, servers.tailwindcss, {
        capabilities = capabilities,
      })
      vim.lsp.enable('tailwindcss')

      local ensure_installed = vim.tbl_filter(function(server)
        return server ~= 'tailwindcss'
      end, vim.tbl_keys(servers or {}))
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
        'prettierd', -- Used to format JS/TS/JSON/Astro via conform
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            if server_name == 'ts_ls' or server_name == 'tsgo' or server_name == 'tailwindcss' then
              return
            end

            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for ts_ls)
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            vim.lsp.config[server_name] = server
            vim.lsp.enable(server_name)
          end,
        },
      }
    end,
  },
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'never' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = true,
      format_on_save = function(bufnr)
        local lsp_fallback = { c = true, cpp = true }
        return {
          timeout_ms = 1000,
          lsp_format = lsp_fallback[vim.bo[bufnr].filetype] and 'fallback' or 'never',
        }
      end,
      formatters_by_ft = {
        astro = { 'prettierd' },
        javascript = { 'prettierd' },
        javascriptreact = { 'prettierd' },
        typescript = { 'prettierd' },
        typescriptreact = { 'prettierd' },
        json = { 'prettierd' },
        gleam = { 'gleam' },
      },
    },
  },
  {
    'dmmulroy/ts-error-translator.nvim',
    config = function()
      require('ts-error-translator').setup()
    end,
  },
}
