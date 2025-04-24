-- ~/.config/nvim/lua/plugins/debug.lua
return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      { 'rcarriga/nvim-dap-ui', dependencies = { 'nvim-neotest/nvim-nio' } },
      'williamboman/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',
      'theHamsta/nvim-dap-virtual-text',
      'nvim-treesitter/nvim-treesitter', -- Required for virtual text
    },
    config = function()
      -- Basic dapui setup
      require('dapui').setup()

      -- Basic mason-nvim-dap setup
      require('mason-nvim-dap').setup {
        ensure_installed = { 'python' },
        handlers = {}, -- Use default handlers
      }

      require('dap').configurations.python = {
        {
          type = 'python',
          request = 'launch',
          name = 'Launch file',
          program = '${file}',
          pythonPath = function()
            -- Check for active virtualenv first
            if vim.env.VIRTUAL_ENV then
              return vim.env.VIRTUAL_ENV .. '/bin/python'
            end
            -- Otherwise use system Python
            return vim.fn.exepath 'python3' or vim.fn.exepath 'python' or 'python'
          end,
        },
      }

      -- NOTE: Haven't messed around with this much yet
      require('nvim-dap-virtual-text').setup {
        enabled = true,                     -- enable this plugin (the default)
        enabled_commands = true,            -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
        highlight_changed_variables = true, -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
        highlight_new_as_changed = false,   -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
        show_stop_reason = true,            -- show stop reason when stopped for exceptions
        commented = false,                  -- prefix virtual text with comment string
        only_first_definition = true,       -- only show virtual text at first definition (if there are multiple)
        all_references = false,             -- show virtual text on all all references of the variable (not only definitions)
        clear_on_continue = false,          -- clear virtual text on "continue" (might cause flickering when stepping)
        --- A callback that determines how a variable is displayed or whether it should be omitted
        --- @param variable Variable https://microsoft.github.io/debug-adapter-protocol/specification#Types_Variable
        --- @param buf number
        --- @param stackframe dap.StackFrame https://microsoft.github.io/debug-adapter-protocol/specification#Types_StackFrame
        --- @param node userdata tree-sitter node identified as variable definition of reference (see `:h tsnode`)
        --- @param options nvim_dap_virtual_text_options Current options for nvim-dap-virtual-text
        --- @return string|nil A text how the virtual text should be displayed or nil, if this variable shouldn't be displayed
        display_callback = function(variable, buf, stackframe, node, options)
          -- by default, strip out new line characters
          if options.virt_text_pos == 'inline' then
            return ' = ' .. variable.value:gsub('%s+', ' ')
          else
            return variable.name .. ' = ' .. variable.value:gsub('%s+', ' ')
          end
        end,
        -- position of virtual text, see `:h nvim_buf_set_extmark()`, default tries to inline the virtual text. Use 'eol' to set to end of line
        virt_text_pos = vim.fn.has 'nvim-0.10' == 1 and 'inline' or 'eol',

        -- experimental features:
        all_frames = false,      -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
        virt_lines = false,      -- show virtual lines instead of virtual text (will flicker!)
        virt_text_win_col = nil, -- position the virtual text at a fixed window column (starting from the first text column) ,
        -- e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
      }

      -- Core debugging
      vim.keymap.set('n', '<leader>dc', require('dap').continue, { desc = 'Debug: Start/Continue' })
      vim.keymap.set('n', '<leader>dp', require('dap').pause, { desc = 'Debug: Pause' })
      vim.keymap.set('n', '<leader>dx', require('dap').terminate, { desc = 'Debug: Exit' })
      vim.keymap.set('n', '<leader>db', require('dap').toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
      vim.keymap.set('n', '<leader>dB', function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end, { desc = 'Debug: Set Conditional Breakpoint' })
      vim.keymap.set('n', '<leader>dC', require('dap').clear_breakpoints, { desc = 'Debug: Clear all breakpoints' })

      -- Stepping
      vim.keymap.set('n', '<leader>j', require('dap').step_over, { desc = 'Debug: Step Over' })
      vim.keymap.set('n', '<leader>i', require('dap').step_into, { desc = 'Debug: Step Into' })
      vim.keymap.set('n', '<C-l>', require('dap').step_over, { desc = 'Debug: Step Over' })
      vim.keymap.set('n', '<C-h>', require('dap').step_into, { desc = 'Debug: Step Into' })
      vim.keymap.set('n', '<leader>do', require('dap').step_out, { desc = 'Debug: Step Out' })

      -- UI Controls
      vim.keymap.set('n', '<leader>du', require('dapui').toggle, { desc = 'Debug: Toggle UI' })
      vim.keymap.set('n', '<leader>dr', require('dap').repl.toggle, { desc = 'Debug: Toggle REPL' })

      -- Information & Control
      vim.keymap.set('n', '<leader>dl', require('dap').run_last, { desc = 'Debug: Run Last' })
      vim.keymap.set('n', '<leader>dh', require('dap.ui.widgets').hover, { desc = 'Debug: Hover Variables' })
      vim.keymap.set('n', '<leader>dv', require('dap.ui.widgets').preview, { desc = 'Debug: Preview' })
    end,
  },
  {
    'folke/trouble.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      focus = true,
    },
    cmd = 'Trouble',
    keys = {
      {
        '<leader>xx',
        '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
        desc = 'Diagnostics (Trouble)',
      },
      {
        '<leader>xe',
        '<cmd>Trouble diagnostics toggle filter.severity=vim.diagnostic.severity.ERROR<cr>',
        desc = 'Diagnostics Error (Trouble)',
      },
      {
        '<leader>xw',
        '<cmd>Trouble diagnostics toggle filter={"not"={severity=vim.diagnostic.severity.INFO}}<cr>',
        desc = 'Show Warnings & Errors (Trouble)',
      },
      {
        '<leader>xX',
        '<cmd>Trouble diagnostics toggle<cr>',
        desc = 'All Buffer Diagnostics (Trouble)',
      },
      {
        '<leader>xs',
        '<cmd>Trouble symbols toggle focus=false<cr>',
        desc = 'Symbols (Trouble)',
      },
      {
        '<leader>xl',
        '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
        desc = 'LSP Definitions / references / ... (Trouble)',
      },
      {
        '<leader>xL',
        '<cmd>Trouble loclist toggle<cr>',
        desc = 'Location List (Trouble)',
      },
      {
        '<leader>xQ',
        '<cmd>Trouble qflist toggle<cr>',
        desc = 'Quickfix List (Trouble)',
      },
    },
  },
  {
    'rachartier/tiny-inline-diagnostic.nvim',
    event = 'VeryLazy', -- Or `LspAttach`
    priority = 1000,    -- needs to be loaded in first
    config = function()
      require('tiny-inline-diagnostic').setup {
        preset = 'modern',
        options = {
          severity = {
            vim.diagnostic.severity.ERROR,
            vim.diagnostic.severity.WARN,
          },
          multiple_diag_under_cursor = true,
          multilines = true,
          show_all_diags_on_cursorline = true,
          overflow = { mode = 'wrap' },

          format = function(diagnostic)
            local bufnr = vim.api.nvim_get_current_buf()
            local line = diagnostic.lnum
            local all_diags = vim.diagnostic.get(bufnr, {
              lnum = line,
            })

            local highest_severity = diagnostic.severity
            for _, d in ipairs(all_diags) do
              if d.severity < highest_severity then -- Lower number means higher severity
                highest_severity = d.severity
              end
            end

            diagnostic.severity = highest_severity
            return diagnostic.message
          end,
        },
      }
    end,
    -- Disable Neovim's built-in virtual text diagnostics
    vim.diagnostic.config({
      virtual_text = false, -- Turn off built-in virtual text
      signs = true,         -- Keep the signs in the gutter
      underline = true,     -- Keep underlining issues
      update_in_insert = false,
      severity_sort = true,
    })
  },
}
