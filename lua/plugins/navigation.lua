-- ~/.config/nvim/lua/plugins/editor.lua
return {
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {
      modes = {
        char = {
          enabled = false,
          jump_labels = false,
        },
      },
    },
    init = function()
      vim.api.nvim_create_autocmd('ColorScheme', {
        pattern = '*',
        callback = function()
          vim.api.nvim_set_hl(0, 'FlashLabel', { bg = '#FF0000', fg = '#000000', bold = true })
        end,
      })
    end,
    keys = {
      {
        'f',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').jump()
        end,
        desc = 'Flash',
      },
      {
        'F',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').treesitter()
        end,
        desc = 'Flash Treesitter',
      },
      {
        '<c-h>',
        mode = { 'c' },
        function()
          require('flash').toggle()
        end,
        desc = 'Toggle Flash Search',
      },
    },
  },
  {
    'cbochs/grapple.nvim', -- For quick file navigation
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    opts = {
      icons = true, -- setting to "true" requires "nvim-web-devicons"
      status = false,
      storage = 'json',
    },
    keys = {
      { '<leader>a', '<cmd>Grapple toggle<cr>', desc = 'Tag a file' },
      { '<C-e>', '<cmd>Grapple toggle_tags<cr>', desc = 'Toggle tags menu' },

      { '<leader>1', '<cmd>Grapple select index=1<cr>', desc = 'Select first tag' },
      { '<leader>2', '<cmd>Grapple select index=2<cr>', desc = 'Select second tag' },
      { '<leader>3', '<cmd>Grapple select index=3<cr>', desc = 'Select third tag' },
      { '<leader>4', '<cmd>Grapple select index=4<cr>', desc = 'Select fourth tag' },

      { '<C-l>', '<cmd>Grapple cycle_tags next<cr>', desc = 'Go to next tag' },
      { '<C-h>', '<cmd>Grapple cycle_tags prev<cr>', desc = 'Go to previous tag' },
    },
  },

  {
    'jake-stewart/multicursor.nvim',
    branch = '1.0',
    config = function()
      local mc = require 'multicursor-nvim'

      mc.setup()

      local set = vim.keymap.set

      -- Add or skip cursor above/below the main cursor.
      set({ 'n', 'v' }, '<leader>mk', function()
        mc.lineAddCursor(-1)
      end, { desc = 'Add cursor one line above' })
      set({ 'n', 'v' }, '<leader>mj', function()
        mc.lineAddCursor(1)
      end, { desc = 'Add cursor one line below' })
      set({ 'n', 'v' }, '<leader>mK', function()
        mc.lineSkipCursor(-1)
      end, { desc = 'Skip adding cursor one line above' })
      set({ 'n', 'v' }, '<leader>mJ', function()
        mc.lineSkipCursor(1)
      end, { desc = 'Skip adding cursor one line below' })

      -- Rotate between cursors
      set({ 'n', 'v' }, '<leader>mh', mc.nextCursor, { desc = 'Move to next cursor' })
      set({ 'n', 'v' }, '<leader>ml', mc.prevCursor, { desc = 'Move to previous cursor' })
      -- Mouse control
      set('n', '<c-leftmouse>', mc.handleMouse, { desc = 'Add/remove cursor at mouse click' })
      -- Toggle cursor at current position
      set({ 'n', 'v' }, '<c-q>', mc.toggleCursor, { desc = 'Toggle cursor at current position' })

      -- Add or skip adding a new cursor by matching word/selection
      set({ 'n', 'v' }, '<leader>mn', function()
        mc.matchAddCursor(1)
      end, { desc = 'MCursor: Add at next match' })
      set({ 'n', 'v' }, '<leader>mN', function()
        mc.matchAddCursor(-1)
      end, { desc = 'MCursor: Add at previous match' })
      set({ 'n', 'v' }, '<leader>ms', function()
        mc.matchSkipCursor(1)
      end, { desc = 'MCursor: Skip next match' })
      set({ 'n', 'v' }, '<leader>mS', function()
        mc.matchSkipCursor(-1)
      end, { desc = 'MCursor: Skip previous match' })
      set({ 'n', 'v' }, '<leader>ma', mc.matchAllAddCursors, { desc = 'MCursor: Add all matches' })
      -- Delete current cursor
      set({ 'n', 'v' }, '<leader>md', mc.deleteCursor, { desc = 'Delete current cursor' })
      -- bring back cursors if you accidentally clear them
      set('n', '<leader>mu', mc.restoreCursors, { desc = 'Undo cursor deletion' })
      -- Align cursor columns.
      set('v', '<leader>ma', mc.alignCursors, { desc = 'Align cursor columns' })

      -- ESC handling for cursors
      set('n', '<esc>', function()
        if not mc.cursorsEnabled() then
          mc.enableCursors()
        elseif mc.hasCursors() then
          mc.clearCursors()
        else
          -- Default <esc> handler.
        end
      end, { desc = 'Enable cursors, clear if active, or normal ESC' })

      -- Visual mode operations
      set('v', 'S', mc.splitCursors, { desc = 'Split selection into cursors at regex matches' })
      set('v', 'I', mc.insertVisual, { desc = 'Insert at start of each selected line' })
      set('v', 'A', mc.appendVisual, { desc = 'Append at end of each selected line' })
      set('v', 'M', mc.matchCursors, { desc = 'Add cursors at regex matches in selection' })

      -- Rotate/transpose operations
      set('v', '<leader>mt', function()
        mc.transposeCursors(1)
      end, { desc = 'Rotate selected texts forward' })

      set('v', '<leader>mT', function()
        mc.transposeCursors(-1)
      end, { desc = 'Rotate selected texts backward' })

      -- Customize how cursors look.
      local hl = vim.api.nvim_set_hl
      hl(0, 'MultiCursorCursor', { link = 'Cursor' })
      hl(0, 'MultiCursorVisual', { link = 'Visual' })
      hl(0, 'MultiCursorSign', { link = 'SignColumn' })
      hl(0, 'MultiCursorDisabledCursor', { link = 'Visual' })
      hl(0, 'MultiCursorDisabledVisual', { link = 'Visual' })
      hl(0, 'MultiCursorDisabledSign', { link = 'SignColumn' })
    end,
  },

  {
    'mikavilpas/yazi.nvim',
    event = 'VeryLazy',
    keys = {
      -- Your keymappings here
      {
        '<leader>e',
        '<cmd>Yazi<cr>',
        desc = 'Open yazi at the current file',
      },
      {
        '<leader>y',
        '<cmd>Yazi toggle<cr>',
        desc = 'Resume the last yazi session',
      },
      {
        '<c-up>',
        '<cmd>Yazi toggle<cr>',
        desc = 'Resume the last yazi session',
      },
    },
    opts = {
      open_for_directories = true,
      keymaps = false,
      integrations = {
        resolve_relative_path_application = 'realpath',
      },
      clipboard_register = 'unnamedplus',
    },
  },
  {
    'bassamsdata/namu.nvim',
    opts = {
      global = {},
      namu_symbols = { -- Specific Module options
        options = {},
      },
    },
    -- === Suggested Keymaps: ===
    vim.keymap.set('n', '<leader>ss', ':Namu symbols<cr>', {
      desc = 'Jump to LSP symbol',
      silent = true,
    }),
    vim.keymap.set('n', '<leader>sp', ':Namu workspace<cr>', {
      desc = 'LSP Symbols - Project',
      silent = true,
    }),
  },
}
