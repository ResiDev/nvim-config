-- Nvim 0.12 ships a builtin `:lsp` command (`:lsp enable|disable|restart|stop`),
-- and nvim-lspconfig's plugin/lspconfig.lua bails out at the top when it finds one:
--
--   if vim.fn.exists(':lsp') == 2 then return end
--
-- so none of its helper commands (`:LspInfo`, `:LspLog`, `:LspStart`, `:LspRestart`)
-- are ever created. Recreate the two diagnostics-only ones; use `:lsp restart` and
-- friends for lifecycle.
vim.api.nvim_create_user_command('LspInfo', 'checkhealth vim.lsp', { desc = 'Alias to `:checkhealth vim.lsp`' })

vim.api.nvim_create_user_command('LspLog', function()
  vim.cmd('tabnew ' .. vim.fn.fnameescape(vim.lsp.log.get_filename()))
end, { desc = 'Open the Nvim LSP client log' })

-- The log defaults to WARN, which hides spawn/handshake detail. Bump it, then
-- `:lsp restart` the server you are debugging and read `:LspLog`.
vim.api.nvim_create_user_command('LspLogLevel', function(info)
  local level = info.args ~= '' and info.args or 'debug'
  vim.lsp.set_log_level(level)
  vim.notify(('LSP log level: %s (%s)'):format(level, vim.lsp.log.get_filename()))
end, {
  nargs = '?',
  complete = function()
    return { 'trace', 'debug', 'info', 'warn', 'error', 'off' }
  end,
  desc = 'Set the LSP client log level (default: debug)',
})
