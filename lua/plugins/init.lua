-- ~/.config/nvim/lua/plugins/init.lua
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- Load all plugin specifications from separate files
require('lazy').setup({
    -- Import all plugins from subdirectories
    { 'ellisonleao/dotenv.nvim' },

    { import = 'plugins.ui' },
    { import = 'plugins.telescope' },
    { import = 'plugins.navigation' },
    { import = 'plugins.lsp-and-format' },
    { import = 'plugins.treesitter' },
    { import = 'plugins.completion' },
    { import = 'plugins.git' },
    { import = 'plugins.claudecode' },
    { import = 'plugins.debug-and-errors' },
    { import = 'plugins.snacks' },
    { import = 'plugins.dadbod' },
    { import = 'plugins.experiment' },
  },
  -- Opts
  {
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
