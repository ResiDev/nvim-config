-- ~/.config/nvim/lua/plugins/git.lua
return {
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
          if vim.wo.diff then return ']c' end
          vim.schedule(function() gs.next_hunk() end)
          return '<Ignore>'
        end, { expr = true, desc = 'Next hunk' })

        map('n', '[c', function()
          if vim.wo.diff then return '[c' end
          vim.schedule(function() gs.prev_hunk() end)
          return '<Ignore>'
        end, { expr = true, desc = 'Previous hunk' })

        -- Actions
        map('n', '<leader>gd', gs.diffthis, { desc = 'Diff against the index' })
        map('n', '<leader>gD', function() gs.diffthis('~') end, { desc = 'Diff against last commit' })
        map('n', '<leader>ga', function() gs.diffthis('@') end, { desc = 'Diff against staged' })
      end,
    },
  }
}
