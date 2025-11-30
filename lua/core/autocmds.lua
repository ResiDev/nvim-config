vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.opt.clipboard = 'unnamedplus'
if vim.fn.has 'wsl' == 1 then
  vim.g.clipboard = {
    name = 'win32yank',
    copy = {
      ['+'] = 'win32yank.exe -i --crlf',
      ['*'] = 'win32yank.exe -i --crlf',
    },
    paste = {
      ['+'] = 'win32yank.exe -o --lf',
      ['*'] = 'win32yank.exe -o --lf',
    },
    cache_enabled = true,
  }
end

-- For specific file types that commonly use 2 spaces
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'lua', 'yaml', 'html', 'css', 'javascript', 'typescript', 'json', 'typescriptreact', 'javascriptreact' },

  callback = function()
    vim.bo.shiftwidth = 2
    vim.bo.tabstop = 2
    vim.bo.softtabstop = 2
  end,
})

-- NOTE: File specific terminal autocmds

-- Python
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'python',
  callback = function()
    vim.keymap.set('n', '<leader><CR>', function()
      local file_path = vim.api.nvim_buf_get_name(0)
      vim.cmd.vnew()
      vim.cmd.terminal()
      job_id = vim.bo.channel
      vim.cmd.wincmd 'J'
      vim.api.nvim_win_set_height(0, 15)
      vim.fn.chansend(job_id, { 'uv run ' .. file_path .. '\r\n' })
    end, { buffer = true })
  end,
})

-- sql
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'sql',
  callback = function()
    vim.keymap.set('n', '<leader><CR>', function()
      local file_path = vim.api.nvim_buf_get_name(0)
      vim.cmd.vnew()
      vim.cmd.terminal()
      local job_id = vim.bo.channel
      vim.cmd.wincmd 'J'
      vim.api.nvim_win_set_height(0, 15)
      vim.fn.chansend(job_id, { 'duckdb < ' .. file_path .. '\r\n' })
    end, { buffer = true })
  end,
})

-- Zig
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'zig',
  callback = function()
    vim.keymap.set('n', '<leader><CR>', function()
      local file_path = vim.api.nvim_buf_get_name(0)
      vim.cmd.vnew()
      vim.cmd.terminal()
      job_id = vim.bo.channel
      vim.cmd.wincmd 'J'
      vim.api.nvim_win_set_height(0, 15)
      vim.fn.chansend(job_id, { 'zig run' .. file_path .. '\r\n' })
    end, { buffer = true })
  end,
})

-- Typescript
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'typescript',
  callback = function()
    vim.keymap.set('n', '<leader><CR>', function()
      local file_path = vim.api.nvim_buf_get_name(0)
      vim.cmd.vnew()
      vim.cmd.terminal()
      job_id = vim.bo.channel
      vim.cmd.wincmd 'J'
      vim.api.nvim_win_set_height(0, 15)
      vim.fn.chansend(job_id, { 'npx tsx ' .. file_path .. '\r\n' })
    end, { buffer = true })
  end,
})

-- Rust
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'rust',
  callback = function()
    vim.keymap.set('n', '<leader><CR>', function()
      local file_path = vim.api.nvim_buf_get_name(0)
      local dir = vim.fn.fnamemodify(file_path, ':p:h')
      -- Instead of the file path, just run 'cargo run'
      -- This will run the default binary for the package you are currently in.
      vim.cmd.vnew()
      vim.cmd.terminal()
      job_id = vim.bo.channel
      vim.cmd.wincmd 'J'
      vim.api.nvim_win_set_height(0, 15)

      vim.fn.chansend(job_id, { 'cd ' .. vim.fn.shellescape(dir) .. '\r\n' })
      vim.fn.chansend(job_id, { 'cargo run\r\n' })
    end, { buffer = true })
  end,
})

-- Gleam
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'gleam',
  callback = function()
    vim.keymap.set('n', '<leader><CR>', function()
      local file_path = vim.api.nvim_buf_get_name(0)
      local dir = vim.fn.fnamemodify(file_path, ':p:h')

      vim.cmd.vnew()
      vim.cmd.terminal()
      local job_id = vim.bo.channel
      vim.cmd.wincmd 'J'
      vim.api.nvim_win_set_height(0, 15)

      -- cd into the file's directory, then run gleam
      vim.fn.chansend(job_id, { 'cd ' .. vim.fn.shellescape(dir) .. '\r\n' })
      vim.fn.chansend(job_id, { 'gleam run\r\n' })
    end, { buffer = true })
  end,
})

-- Mojo
vim.api.nvim_create_autocmd('BufRead', {
  pattern = '*.mojo',
  callback = function()
    vim.keymap.set('n', '<leader><CR>', function()
      local file_path = vim.api.nvim_buf_get_name(0)
      local dir = vim.fn.fnamemodify(file_path, ':p:h')

      vim.cmd.vnew()
      vim.cmd.terminal()
      local job_id = vim.bo.channel
      vim.cmd.wincmd 'J'
      vim.api.nvim_win_set_height(0, 15)

      -- cd into the file's directory, then run mojo
      vim.fn.chansend(job_id, { 'cd ' .. vim.fn.shellescape(dir) .. '\r\n' })
      vim.fn.chansend(job_id, { 'uv run mojo ' .. file_path .. '\r\n' })
    end, { buffer = true })
  end,
})

vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = '*',
  callback = function()
    vim.api.nvim_set_hl(0, 'FlashLabel', { bg = '#FF0000', fg = '#000000', bold = true })
  end,
})
