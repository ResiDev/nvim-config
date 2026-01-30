-- Claude Code helper keymaps
-- Copy context to clipboard for pasting into Claude Code

-- Copy current file path as @relative/path
vim.keymap.set('n', '<C-.>', function()
  local relpath = vim.fn.expand '%:.'
  if relpath ~= '' then
    vim.fn.setreg('+', '@' .. relpath .. ' ')
    vim.notify('Copied: @' .. relpath)
  end
end, { desc = 'Copy file path for Claude Code' })

-- Copy selection with file path and line numbers
vim.keymap.set('v', '<C-.>', function()
  local relpath = vim.fn.expand '%:.'
  local start_line = vim.fn.line 'v'
  local end_line = vim.fn.line '.'
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local text = '@' .. relpath .. ' [' .. start_line .. '-' .. end_line .. ']\n' .. table.concat(lines, '\n')
  vim.fn.setreg('+', text)
  vim.notify('Copied: @' .. relpath .. ' [' .. start_line .. '-' .. end_line .. ']')
  -- Exit visual mode
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
end, { desc = 'Copy selection with path for Claude Code' })

-- Copy LSP diagnostics
local function copy_diagnostics(start_line, end_line)
  local relpath = vim.fn.expand '%:.'
  local bufnr = vim.api.nvim_get_current_buf()
  local diagnostics = vim.diagnostic.get(bufnr)

  if start_line and end_line then
    diagnostics = vim.tbl_filter(function(d)
      return d.lnum + 1 >= start_line and d.lnum + 1 <= end_line
    end, diagnostics)
  end

  if #diagnostics == 0 then
    vim.notify('No diagnostics found', vim.log.levels.INFO)
    return
  end

  local severity_map = { 'ERROR', 'WARN', 'INFO', 'HINT' }
  local lines = { '@' .. relpath }
  for _, d in ipairs(diagnostics) do
    local sev = severity_map[d.severity] or 'UNKNOWN'
    table.insert(lines, sev .. ' [' .. (d.lnum + 1) .. ']: ' .. d.message)
  end

  vim.fn.setreg('+', table.concat(lines, '\n'))
  vim.notify('Copied ' .. #diagnostics .. ' diagnostic(s)')
end

vim.keymap.set('n', '<C-;>', function()
  copy_diagnostics()
end, { desc = 'Copy all diagnostics for Claude Code' })

vim.keymap.set('v', '<C-;>', function()
  local start_line = vim.fn.line 'v'
  local end_line = vim.fn.line '.'
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
  copy_diagnostics(start_line, end_line)
end, { desc = 'Copy selection diagnostics for Claude Code' })
