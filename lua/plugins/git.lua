-- ~/.config/nvim/lua/plugins/git.lua
return {
  {
    'sindrets/diffview.nvim',
    cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewFileHistory' },
    keys = {
      { '<leader>gv', '<cmd>DiffviewOpen<cr>', desc = 'Open diff view' },
      { '<leader>gV', '<cmd>DiffviewClose<cr>', desc = 'Close diff view' },
      { '<leader>gh', '<cmd>DiffviewFileHistory %<cr>', desc = 'File history' },
    },
    config = function()
      require('diffview').setup {
        enhanced_diff_hl = true, -- Better inline highlighting
        view = {
          default = {
            layout = 'diff2_horizontal',
          },
        },
      }
    end,
  },
  { 'akinsho/git-conflict.nvim', version = '*', config = true },
  -- {
  --   "kdheepak/lazygit.nvim",
  --   lazy = true,
  --   cmd = {
  --     "LazyGit",
  --     "LazyGitConfig",
  --     "LazyGitCurrentFile",
  --     "LazyGitFilter",
  --     "LazyGitFilterCurrentFile",
  --   },
  --   -- optional for floating window border decoration
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --   },
  --   -- setting the keybinding for LazyGit with 'keys' is recommended in
  --   -- order to load the plugin when the command is run for the first time
  --   keys = {
  --     { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" }
  --   }
  -- },

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

        -- Actions
        map('n', '<leader>gd', function()
          gs.diffthis '~'
        end, { desc = 'Diff against last commit' })
        map('n', '<leader>gD', gs.diffthis, { desc = 'Diff against the index' })
        map('n', '<leader>ga', function()
          gs.diffthis '@'
        end, { desc = 'Diff against staged' })
      end,
    },
  },
}
