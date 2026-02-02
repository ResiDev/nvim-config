return {
  {
    'ellisonleao/dotenv.nvim',
    lazy = false,
    config = function()
      require('dotenv').setup()

      vim.cmd('Dotenv ' .. vim.fn.stdpath 'config' .. '/.env')
    end,
  },
  -- {
  --   'greggh/claude-code.nvim',
  --   dependencies = {
  --     'nvim-lua/plenary.nvim', -- Required for git operations
  --   },
  --   opts = {
  --     window = {
  --       position = 'botright vsplit',
  --       split_ratio = 0.3, -- 30% of screen width
  --       enter_insert = false, -- Don't auto-enter insert mode
  --     },
  --     keymaps = {
  --       toggle = {
  --         normal = '<C-.>', -- Normal mode keymap for toggling Claude Code, false to disable
  --         terminal = '<C-.>', -- Terminal mode keymap for toggling Claude Code, false to disable
  --         variants = {
  --           continue = '<leader>cc', -- Normal mode keymap for Claude Code with continue flag
  --           verbose = '<leader>cv', -- Normal mode keymap for Claude Code with verbose flag
  --         },
  --       },
  --
  --       window_navigation = false, -- Disable to avoid conflicts with your <C-j/k> keymaps
  --       scrolling = true, -- Keep <C-f/b> for scrolling
  --     },
  --   },
  --   config = function(_, opts)
  --     require('claude-code').setup(opts)
  --
  --     -- Toggle fullscreen for Claude Code window
  --     local claude_tab = nil
  --     local function toggle_fullscreen()
  --       local current_buf = vim.api.nvim_get_current_buf()
  --       local buf_name = vim.api.nvim_buf_get_name(current_buf)
  --
  --       -- Check if we're in a Claude Code buffer
  --       if not buf_name:match('claude%-code') then
  --         vim.notify('Not in Claude Code window', vim.log.levels.WARN)
  --         return
  --       end
  --
  --       if claude_tab then
  --         -- Return from fullscreen - close the tab
  --         vim.cmd('tabclose')
  --         claude_tab = nil
  --       else
  --         -- Go fullscreen - move to new tab
  --         claude_tab = vim.fn.tabpagenr()
  --         vim.cmd('tab split')
  --       end
  --     end
  --
  --     vim.keymap.set('n', '<leader>cf', toggle_fullscreen, { desc = 'Toggle Claude Code fullscreen' })
  --   end,
  -- },
}
