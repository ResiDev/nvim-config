-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- [[ Setting options ]]
-- See `:help vim.opt`

-- Make line relatve numbers default
vim.opt.relativenumber = true
vim.opt.number = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
--  Setting yank to copy to clipboard (wsl)
vim.opt.clipboard = 'unnamedplus'

if vim.fn.has 'wsl' == 1 then
  vim.api.nvim_create_autocmd('TextYankPost', {
    group = vim.api.nvim_create_augroup('Yank', { clear = true }),
    callback = function()
      vim.schedule(function()
        local clipboard_content = vim.fn.getreg '"'
        if clipboard_content ~= '' then
          local result = vim.fn.system('clip.exe', clipboard_content)
          if vim.v.shell_error ~= 0 then
            print('Failed to copy to Windows clipboard: ' .. result)
          else
            print('Copied to Windows clipboard: ' .. string.sub(clipboard_content, 1, 20) .. '...')
          end
        end
      end)
    end,
  })
end

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Indentation settings
vim.opt.expandtab = true -- Convert tabs to spaces
vim.opt.shiftwidth = 4   -- Number of spaces for indentation
vim.opt.tabstop = 4      -- Number of spaces a tab counts for
vim.opt.softtabstop = 4  -- Number of spaces a tab counts for while editing

-- For specific file types that commonly use 2 spaces
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'lua', 'yaml', 'html', 'css' },
  callback = function()
    vim.bo.shiftwidth = 2
    vim.bo.tabstop = 2
    vim.bo.softtabstop = 2
  end,
})
--
-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`
vim.keymap.set('i', '<C-BS>', '<C-w>', { desc = 'Delete word backward' })
vim.keymap.set('i', '<C-h>', '<C-w>', { desc = 'Delete word backward' }) -- Terminal compatibility

-- [[ Remapped keys ]]
vim.keymap.set('n', 's', 'r', { noremap = true })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { noremap = true })
vim.keymap.set('n', '<C-d>', '<C-d>zz', { noremap = true })

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', ':noh', { noremap = true })

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Disabling diagnostic for plugin instead
vim.diagnostic.config {
  virtual_text = false, -- This controls the right-side diagnostics
}

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
-- vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', 'gh', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', 'gl', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', 'gk', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
vim.keymap.set('n', 'gj', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
-- vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
-- vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Nvim Terminal
vim.api.nvim_set_keymap('t', '<Esc>', '<C-\\><C-n>', { noremap = true }) -- Map Esc in terminal
local job_id = 0
vim.api.nvim_create_autocmd('TermOpen', {
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end,
})
vim.keymap.set('n', '<leader>t', function()
  vim.cmd.vnew()
  vim.cmd.terminal()
  vim.cmd.wincmd 'J'
  vim.cmd 'startinsert'
  vim.api.nvim_win_set_height(0, 15)
end, { desc = 'Terminal: Open' })

-- Terminal and run python
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'python',
  callback = function()
    local file_path = vim.api.nvim_buf_get_name(0)
    vim.keymap.set('n', '<leader><CR>', function()
      vim.cmd.vnew()
      vim.cmd.terminal()
      job_id = vim.bo.channel
      vim.cmd.wincmd 'J'
      vim.api.nvim_win_set_height(0, 15)
      vim.fn.chansend(job_id, { 'uv run ' .. file_path .. '\r\n' })
    end)
  end,
})

-- Terminal and run zig
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'zig',
  callback = function()
    local file_path = vim.api.nvim_buf_get_name(0)
    vim.keymap.set('n', '<leader><CR>', function()
      vim.cmd.vnew()
      vim.cmd.terminal()
      job_id = vim.bo.channel
      vim.cmd.wincmd 'J'
      vim.api.nvim_win_set_height(0, 15)
      vim.fn.chansend(job_id, { 'zig run' .. file_path .. '\r\n' })
    end)
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'typescript',
  callback = function()
    local file_path = vim.api.nvim_buf_get_name(0)
    vim.keymap.set('n', '<leader><CR>', function()
      vim.cmd.vnew()
      vim.cmd.terminal()
      job_id = vim.bo.channel
      vim.cmd.wincmd 'J'
      vim.api.nvim_win_set_height(0, 15)
      vim.fn.chansend(job_id, { 'ts-node ' .. file_path .. '\r\n' })
    end)
  end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update

-- NOTE: PLUGINS
require('lazy').setup({
  -- 'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
  {
    "nvzone/typr",
    dependencies = "nvzone/volt",
    opts = {},
    cmd = { "Typr", "TyprStats" },
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
  },

  -- {
  --   'jinh0/eyeliner.nvim', -- Adds highlighting for f/F jumps
  --   config = function()
  --     require('eyeliner').setup { highlight_on_key = true }
  --   end,
  -- },

  {
    'folke/snacks.nvim',
    priority = 1000, -- Add this since it's recommended in the docs
    lazy = false,    -- Add this since some features need early loading
    opts = {
      lazygit = { enabled = true },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      -- terminal = { enabled = true },
      dashboard = { enabled = true },
      scratch = {
        enabled = true,
        win_by_ft = {
          python = {
            keys = {
              ['source'] = {
                '<leader>r',
                function(self)
                  vim.cmd 'write !python3'
                end,
                desc = 'Run Python buffer',
                mode = { 'n', 'x' },
              },
            },
          },
        },
      },
    },
    keys = {
      -- Git
      {
        '<leader>gg',
        function()
          require('snacks').lazygit()
        end,
        desc = 'Open LazyGit',
      },
      {
        '<leader>gl',
        function()
          require('snacks').lazygit.log()
        end,
        desc = 'Open LazyGit Log',
      },
      {
        '<leader>gf',
        function()
          require('snacks').lazygit.log_file()
        end,
        desc = 'Open LazyGit File Log',
      },
      {
        '<leader>.',
        function()
          Snacks.scratch()
        end,
        desc = 'Toggle Scratch Buffer',
      },
      {
        '<leader>S',
        function()
          Snacks.scratch.select()
        end,
        desc = 'Select Scratch Buffer',
      },
    },
  },

  {
    'folke/flash.nvim',
    event = 'VeryLazy',

    ---@type Flash.Config
    opts = {
      modes = {
        char = {
          enabled = false,
          jump_labels = false
        }
      },
    },

    -- stylua: ignore
    -- Changing highlight colour
    init = function()
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
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
      { '<leader>a', '<cmd>Grapple toggle<cr>',          desc = 'Tag a file' },
      { '<c-e>',     '<cmd>Grapple toggle_tags<cr>',     desc = 'Toggle tags menu' },

      { '<leader>1', '<cmd>Grapple select index=1<cr>',  desc = 'Select first tag' },
      { '<leader>2', '<cmd>Grapple select index=2<cr>',  desc = 'Select second tag' },
      { '<leader>3', '<cmd>Grapple select index=3<cr>',  desc = 'Select third tag' },
      { '<leader>4', '<cmd>Grapple select index=4<cr>',  desc = 'Select fourth tag' },

      { '<c-j>',     '<cmd>Grapple cycle_tags next<cr>', desc = 'Go to next tag' },
      { '<c-k>',     '<cmd>Grapple cycle_tags prev<cr>', desc = 'Go to previous tag' },
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

  { 'akinsho/git-conflict.nvim', version = '*', config = true },

  { -- Adds git signs to gutter, staging stuff with <leader>h, [c and ]c  to navigate "hunks" (change blocks)
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
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            gs.next_hunk()
          end
        end)

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            gs.prev_hunk()
          end
        end)

        map('n', '<leader>gs', gs.stage_hunk, { desc = 'Stage current hunk' })
        map('n', '<leader>gr', gs.reset_hunk, { desc = 'Reset current hunk' })
        map('v', '<leader>gs', function()
          gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'Stage selected lines' })
        map('v', '<leader>gr', function()
          gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'Reset selected lines' })
        map('n', '<leader>gS', gs.stage_buffer, { desc = 'Stage entire buffer' })
        map('n', '<leader>gu', gs.undo_stage_hunk, { desc = 'Undo last stage' })
        map('n', '<leader>gR', gs.reset_buffer, { desc = 'Reset entire buffer' })
        map('n', '<leader>gp', gs.preview_hunk, { desc = 'Preview current hunk' })
        map('n', '<leader>gb', function()
          gs.blame_line { full = true }
        end, { desc = 'Show full blame for line' })
        map('n', '<leader>gb', gs.toggle_current_line_blame, { desc = 'Toggle line blame' })
        map('n', '<leader>gd', gs.diffthis, { desc = 'Diff this file' })
        map('n', '<leader>gD', function()
          gs.diffthis '~'
        end, { desc = 'Diff against parent' })
        map('n', '<leader>gl', gs.toggle_deleted, { desc = 'Toggle deleted lines' })

        -- Text object
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>') -- Allows selection of hunk like vih, dih, yih
      end,
    },
  },

  -- NOTE: Plugins can also be configured to run Lua code when they are loaded.
  -- Like: event = 'VimEnter'
  -- which loads which-key before all the UI elements are loaded. Events can be
  -- normal autocommands events (`:help autocmd-events`).

  {                     -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    opts = {
      icons = {
        mappings = vim.g.have_nerd_font,
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ',
          BS = '<BS> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
          F1 = '<F1>',
          F2 = '<F2>',
          F3 = '<F3>',
          F4 = '<F4>',
          F5 = '<F5>',
          F6 = '<F6>',
          F7 = '<F7>',
          F8 = '<F8>',
          F9 = '<F9>',
          F10 = '<F10>',
          F11 = '<F11>',
          F12 = '<F12>',
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
        { '<leader>m', group = '󰆿 MultiCursor' },
        { '<leader>x', group = 'Trouble' },
        { '<leader>/', group = 'Telescope fuzzy search buffer' },
      },
    },
  },

  {
    'nvim-tree/nvim-web-devicons',
    opts = { color_icons = true, default = true },
    lazy = false,
    enabled = true,
  },

  --@type LazySpec
  {
    'mikavilpas/yazi.nvim',
    event = 'VeryLazy',
    keys = {
      -- 👇 in this section, choose your own keymappings!
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
        -- NOTE: this requires a version of yazi that includes
        -- https://github.com/sxyazi/yazi/pull/1305 from 2024-07-18
        '<c-up>',
        '<cmd>Yazi toggle<cr>',
        desc = 'Resume the last yazi session',
      },
    },
    ---@type YaziConfig
    opts = {
      -- if you want to open yazi instead of netrw, see below for more info
      open_for_directories = true,
      keymaps = false,
      -- keymaps = {
      --   show_help = '<f1>',
      --   open_file_in_vertical_split = '<c-v>',
      --   open_file_in_horizontal_split = '<c-x>',
      --   open_file_in_tab = '<c-t>',
      --   grep_in_directory = '<c-s>',
      --   replace_in_directory = '<c-g>',
      --   cycle_open_buffers = '<tab>',
      --   copy_relative_path_to_selected_files = '<c-y>',
      --   send_to_quickfix_list = '<c-q>',
      --   change_working_directory = '<c-\\>',
      -- },
      integrations = {
        resolve_relative_path_application = 'realpath', -- use "grealpath" if you're on macOS
      },
      clipboard_register = 'unnamedplus',               -- uses system clipboard
    },
  },

  -- NOTE: Telescope
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'debugloop/telescope-undo.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = 'make',

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },

      -- Useful for getting pretty icons, but requires a Nerd Font.
      { 'nvim-tree/nvim-web-devicons',            enabled = vim.g.have_nerd_font },
    },
    -- The easiest way to use Telescope, is to start by doing something like:
    --  :Telescope help_tags
    --
    -- Two important keymaps to use while in Telescope are:
    --  - Insert mode: <c-/> -- cycle through in insert mode
    --  - Normal mode: ?

    -- [[ Configure Telescope ]]
    -- See `:help telescope` and `:help telescope.setup()`
    config = function()
      require('telescope').setup {
        --  All the info you're looking for is in `:help telescope.setup()`
        --
        defaults = {
          mappings = {
            i = {
              -- In insert mode, press ctrl-t to tag current selection
              ['<C-#>'] = function(prompt_bufnr)
                -- Get the selected entry
                local selection = require('telescope.actions.state').get_selected_entry()
                -- Print both the buffer number and the current selection
                local selection = require('telescope.actions.state').get_selected_entry()
                print('Buffer:', prompt_bufnr)
                print('Selection:', vim.inspect(selection))
              end,
            },
          },
        },
        -- pickers = {}
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
          fzf = {},
        },
      }

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')
      require('telescope').load_extension 'undo'

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader>s<leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
      vim.keymap.set('n', '<leader>u', '<cmd>Telescope undo<cr>', { desc = 'Telescope Undo' })

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },

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

  -- LSP Plugins
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
  },

  { 'Bilal2453/luvit-meta',      lazy = true },

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
      { 'j-hui/fidget.nvim',       opts = {} },
      -- Allows extra capabilities provided by nvim-cmp
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
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
          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

          -- Find references for the word under your cursor.
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('<leader>o', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
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

      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/

      local servers = {
        -- clangd = {},
        -- gopls = {},
        -- pyright = {},
        -- rust_analyzer = {},
        -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
        --
        -- Some languages (like typescript) have entire language plugins that can be useful:
        --    https://github.com/pmizio/typescript-tools.nvim
        --
        -- But for many setups, the LSP (`ts_ls`) will work just fine
        -- ts_ls = {},

        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                typeCheckingMode = 'standard',
              },
            },
          },
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

      require('mason').setup()

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
        'basedpyright',
        'ruff',
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for ts_ls)
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },

  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = true,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true, cpp = true }
        local lsp_format_opt
        if disable_filetypes[vim.bo[bufnr].filetype] then
          lsp_format_opt = 'never'
        else
          lsp_format_opt = 'fallback'
        end
        return {
          timeout_ms = 500,
          lsp_format = lsp_format_opt,
        }
      end,
      -- formatters = {
      --   prettierd = {
      --     env = {
      --       PRETTIERD_LOCAL_PRETTIER_ONLY = 'true',
      --     },
      --   },
      --   -- xmlformatter = {
      --   --   command = 'xmlformat',
      --   --   args = { '-' },
      --   -- },
      -- },
      -- formatters_by_ft = {
      --   lua = { 'stylua' },
      --   python = { 'ruff' },
      --   html = { 'prettierd' },
      astro = { 'prettier' },
      --   css = { 'prettierd' },
      --   javascript = { 'prettierd' },
      --   javascriptreact = { 'prettierd' },
      --   typescript = { 'prettierd' },
      --   typescriptreact = { 'prettierd' },
      --   json = { 'prettierd' },
      --   yaml = { 'prettierd' },
      --   -- xml = { 'xmlformatter' },
      --   xml = { 'xmllint' },
      -- },
    },
  },

  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
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
      },
      'saadparwaiz1/cmp_luasnip',

      -- Adds other completion capabilities.
      --  nvim-cmp does not ship with all sources by default. They are split
      --  into multiple repos for maintenance purposes.
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
    },
    config = function()
      -- See `:help cmp`
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      luasnip.config.setup {}

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },

        -- For an understanding of why these mappings were
        -- chosen, you will need to read `:help ins-completion`
        --
        -- No, but seriously. Please read `:help ins-completion`, it is really good!
        mapping = cmp.mapping.preset.insert {
          -- Select the [n]ext item
          ['<C-n>'] = cmp.mapping.select_next_item(),
          -- Select the [p]revious item
          ['<C-p>'] = cmp.mapping.select_prev_item(),

          -- Scroll the documentation window [b]ack / [f]orward
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),

          -- Accept ([y]es) the completion.
          ['<C-y>'] = cmp.mapping.confirm { select = true },
          ['<CR>'] = cmp.mapping.confirm { select = true }, -- Enter
          --['<Tab>'] = cmp.mapping.select_next_item(),
          --['<S-Tab>'] = cmp.mapping.select_prev_item(),

          -- Manually trigger a completion from nvim-cmp.
          -- ['<C-Space>'] = cmp.mapping.complete {},

        },
        sources = {
          -- { name = 'codeium' },
          -- { name = "supermaven" }, -- Annoying as it makes enter key accept the suggestion
          { name = "codecompanion", },
          {
            name = 'lazydev',
            -- set group index to 0 to skip loading LuaLS completions as lazydev recommends it
            group_index = 0,
          },
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
        },
      }
    end,
  },

  {
    "supermaven-inc/supermaven-nvim",
    config = function()
      require("supermaven-nvim").setup({
        keymaps = {
          accept_suggestion = "<Tab>",
          accept_word = "<C-n>"
        }
      })
      vim.keymap.set('n', '<leader>sm', "<cmd>SupermavenToggle<cr>",
        { desc = 'Supermaven Toggle' })
    end,
  },

  -- {
  --   'Exafunction/codeium.nvim',
  --   dependencies = {
  --     'nvim-lua/plenary.nvim',
  --     'hrsh7th/nvim-cmp',
  --   },
  --   config = function()
  --     -- Setup Codeium with configuration options
  --     require('codeium').setup {
  --       autocompletion = true,
  --       virtual_text = {
  --         enabled = true,
  --         idle_delay = 0,
  --         filetypes = {
  --           python = true,
  --           html = true,
  --           javascript = true,
  --           typescript = true,
  --         },
  --         default_filetype_enabled = true,
  --       },
  --     }
  --   end
  -- },

  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = { -- Add this opts table
      adapters = {
        anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", {
            env = {
              api_key = "replace"
            },
          })
        end,
        gemini = function()
          return require("codecompanion.adapters").extend("gemini", {
            env = {
              api_key = "replace",
            },
          })
        end,
      },
      strategies = {
        chat = {
          adapter = "gemini",
          keymaps = {
            send = {
              modes = { n = "<C-s>", i = "<C-s>" },
            },
            next_chat = {
              modes = { n = "<C-n>", i = "<C-n>" },
            },
            previous_chat = {
              modes = { n = "<C-p>", i = "<C-p>" },
            }


          }
        },
        inline = {
          adapter = "gemini",
        },
      },
    },
    vim.keymap.set('n', '<leader>C', "<cmd>CodeCompanionActions<cr>", { desc = 'Code Companion Actions' }),
    vim.keymap.set('v', '<C-c>', ":CodeCompanion", { desc = 'Code Companion Actions' }),
    vim.keymap.set('n', '<leader>c', "<cmd>CodeCompanionChat Toggle<cr>", { desc = 'Code Companion Chat' }),
  },

  {
    'folke/tokyonight.nvim',
    priority = 9000, -- Make sure to load this before all the other start plugins.
    init = function()
      vim.cmd.colorscheme 'tokyonight-night'
      vim.cmd.hi 'Comment gui=none'
    end,
  },

  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end
    end,
  },

  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs', -- Sets main module to use for opts
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
    opts = {
      ensure_installed = {
        'bash',
        'c',
        'diff',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'vim',
        'vimdoc',
        'python',
        'zig',
        'rust',
      },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
    },

    -- {
    --   'nvim-treesitter/nvim-treesitter-context',
    --   dependencies = { 'nvim-treesitter/nvim-treesitter' },
    --   config = function()
    --     require('treesitter-context').setup {
    --       enable = true, -- Can also be toggled with :TSContextEnable, :TSContextDisable, :TSContextToggle commands
    --       multiwindow = false, -- If true, shows context in all Neovim windows
    --       max_lines = 5,
    --       multiline_threshold = 1,
    --       trim_scope = 'inner',
    --       mode = 'cursor',
    --       line_numbers = true,
    --     }
    --   end,
    -- },
    --
    -- {
    --   'nvim-treesitter/nvim-treesitter-textobjects',
    --   dependencies = { 'nvim-treesitter/nvim-treesitter' },
    --   config = function()
    --     require('nvim-treesitter.configs').setup {
    --       textobjects = {
    --         select = {
    --           enable = true,
    --           lookahead = true, -- Automatically jump forward to matching textobj
    --           keymaps = {
    --             -- You use: va to select outer, vi to select inner
    --             ['af'] = '@function.outer', -- Select outer part of a function
    --             ['if'] = '@function.inner', -- Select inner part of a function
    --             ['ac'] = '@class.outer', -- Select outer part of a class
    --             ['ic'] = '@class.inner', -- Select inner part of a class
    --           },
    --         },
    --         move = {
    --           enable = true,
    --           set_jumps = true,
    --           goto_next_start = {
    --             [']]'] = '@function.outer', -- Function start
    --             [']c'] = '@class.outer', -- Class start
    --             [']l'] = '@loop.outer', -- Loop start
    --             [']i'] = '@conditional.outer', -- If start
    --           },
    --           goto_next_end = {
    --             [']['] = '@function.outer', -- Function end
    --             [']C'] = '@class.outer', -- Class end
    --             [']L'] = '@loop.outer', -- Loop end
    --             [']I'] = '@conditional.outer', -- If end
    --           },
    --           goto_previous_start = {
    --             ['[['] = '@function.outer', -- Previous function start
    --             ['[c'] = '@class.outer', -- Previous class start
    --             ['[l'] = '@loop.outer', -- Previous loop start
    --             ['[i'] = '@conditional.outer', -- Previous if start
    --           },
    --           goto_previous_end = {
    --             ['[]'] = '@function.outer', -- Previous function end
    --             ['[C'] = '@class.outer', -- Previous class end
    --             ['[L'] = '@loop.outer', -- Previous loop end
    --             ['[I'] = '@conditional.outer', -- Previous if end
    --           },
    --         },
    --       },
    --     }
    --   end,
    -- },
    --
    -- { -- NOTE: Was causing issues with svelte
    --   'nvim-treesitter/nvim-treesitter-refactor',
    --   dependencies = { 'nvim-treesitter/nvim-treesitter' },
    --   config = function()
    --     require('nvim-treesitter.configs').setup {
    --       refactor = {
    --         -- Highlight definitions
    --         highlight_definitions = {
    --           enable = true,
    --           clear_on_cursor_move = true,
    --         },
    --         -- Highlight current scope
    --         highlight_current_scope = {
    --           enable = false,
    --         },
    --         -- Smart rename
    --         -- smart_rename = {
    --         --   enable = true,
    --         --   keymaps = {
    --         --     smart_rename = 'grr',
    --         --   },
    --         -- },
    --         -- Navigation
    --         navigation = {
    --           enable = true,
    --           keymaps = {
    --             goto_definition = 'gnd',
    --             list_definitions = 'gnD',
    --             list_definitions_toc = 'gO',
    --             goto_next_usage = '<a-d>',
    --             goto_previous_usage = '<a-D>',
    --           },
    --         },
    --       },
    --     }
    --   end,
    -- },
  },

  -- The following two comments only work if you have downloaded the kickstart repo, not just copy pasted the
  -- init.lua. If you want these files, they are in the repository, so you can just download them and
  -- place them in the correct locations.

  -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
  --
  --  Here are some example plugins that I've included in the Kickstart repository.
  --  Uncomment any of the lines below to enable them (you will need to restart nvim).
  --
  -- require 'kickstart.plugins.debug',
  -- require 'kickstart.plugins.indent_line',
  -- require 'kickstart.plugins.lint',
  -- require 'kickstart.plugins.autopairs',
  -- require 'kickstart.plugins.neo-tree',
  -- require 'kickstart.plugins.gitsigns', -- adds gitsigns recommend keymaps

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    This is the easiest way to modularize your config.
  --
  --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --    For additional information, see `:help lazy.nvim-lazy.nvim-structuring-your-plugins`
  -- { import = 'custom.plugins' },
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
