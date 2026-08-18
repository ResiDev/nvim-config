-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Temporary test change (will be reverted)
-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

require 'core.options'
require 'core.keymaps'
require 'core.clipboard-context'
require 'core.autocmds'
require 'core.ask'
require 'core.lsp-debug'
require 'plugins'

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
--
--
