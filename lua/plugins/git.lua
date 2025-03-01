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
        topdelete = { text = 'ΓÇ╛' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gs = require 'gitsigns'

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation and keymaps (abbreviated - include from your original file)
        map('n', ']c', function()
          -- Navigation code here
        end)
        -- Rest of the keymaps
      end,
    },
  },
}
