-- ~/.config/nvim/lua/plugins/git.lua
return {
  {
  "ResiDev/codediff.nvim",
  branch = "fix/dir-scan-ignores",
  cmd = "CodeDiff",
    keys = {
      { '<leader>gd', '<cmd>CodeDiff<cr>',                  desc = 'CodeDiff vs HEAD (inline)' },
      { '<leader>gD', '<cmd>CodeDiff --side-by-side<cr>',   desc = 'CodeDiff vs HEAD (side-by-side)' },
      { '<leader>gH', '<cmd>CodeDiff history<cr>',          desc = 'CodeDiff file history' },

    },
    opts ={
      diff = {
        layout = 'inline',
      },
      explorer = {
        view_mode = 'tree',
        file_filter = {
          -- Explicit (not relying on library defaults); note: this list
          -- REPLACES the defaults, it is not merged with them
          ignore = { '.git/**', '.jj/**', '**/node_modules/**', '**/.worktrees/**', '**/dist/**' },
        },
      },
      keymaps = {
        view = {
          toggle_explorer= '<leader>f',
          focus_explorer='<leader>b'

        }
      }
    }
},
  { 'akinsho/git-conflict.nvim', version = '*', config = true },

  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
        word_diff = true,
      },
      on_attach = function(bufnr)
        local gs = require 'gitsigns'
        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then
            return ']c'
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Next hunk' })

        map('n', '[c', function()
          if vim.wo.diff then
            return '[c'
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Previous hunk' })
      end,
    },
  },
}
