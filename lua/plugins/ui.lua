-- ~/.config/nvim/lua/plugins/ui.lua
return {
  {
    'folke/tokyonight.nvim',
    priority = 9000, -- Make sure to load this before all the other start plugins.
    init = function()
      vim.cmd.colorscheme 'tokyonight-night'
      vim.cmd.hi 'Comment gui=none'
    end,
  },
  {
    'echasnovski/mini.nvim',
    config = function()
      -- Mini.ai setup for improved text objects
      require('mini.ai').setup { n_lines = 500 }

      -- Mini.surround for adding/deleting/replacing surroundings
      require('mini.surround').setup({ n_lines = 500 })

      -- Mini.statusline for the status line
      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- Configure sections in the statusline
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end
    end,
  },
  {
    'nvim-tree/nvim-web-devicons',
    opts = { color_icons = true, default = true },
    lazy = false,
    enabled = true,
  },
  {
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    opts = {
      icons = {
        mappings = vim.g.have_nerd_font,
        keys = vim.g.have_nerd_font and {} or {
          -- Key icons here (truncated for brevity)
        },
      },
      -- Document existing key chains
      spec = {
        { '<leader>c', group = 'Code', mode = { 'n', 'x' } },
        { '<leader>d', group = 'Debug' },
        { '<leader>r', group = '[R]ename' },
        { '<leader>s', group = 'Telescope search' },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>t', group = 'Terminal' },
        { '<leader>g', group = 'Git Hunk', mode = { 'n', 'v' } },
        { '<leader>e', group = 'Yazi file manager' },
        { '<leader>m', group = '≤░å┐ MultiCursor' },
        { '<leader>x', group = 'Trouble' },
        { '<leader>/', group = 'Telescope fuzzy search buffer' },
      },
    },
  },
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
    keys = {
      { "<leader>st", function() Snacks.picker.todo_comments() end,                                          desc = "Todo" },
      { "<leader>sT", function() Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end, desc = "Todo/Fix/Fixme" },
    },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    ---@module "ibl"
    ---@type ibl.config
    opts = {
      scope = {
        enabled = false,
        show_start = false,
        show_end = false,
        highlight = "Identifier",
      },
      indent = {
        char = "⎪",
      }
    },
  },
}
