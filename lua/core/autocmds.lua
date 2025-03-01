vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

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

-- For specific file types that commonly use 2 spaces
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'lua', 'yaml', 'html', 'css' },
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

-- Zig
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

-- Typescript
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


vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, 'FlashLabel', { bg = '#FF0000', fg = '#000000', bold = true })
  end,
})
