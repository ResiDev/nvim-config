-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`
vim.keymap.set('i', '<C-BS>', '<C-w>', { desc = 'Delete word backward' })
vim.keymap.set('i', '<C-h>', '<C-w>', { desc = 'Delete word backward' }) -- Terminal compatibility
vim.keymap.set('i', '<C-h>', '<C-w>', { desc = 'Delete word backward' }) -- Terminal compatibility

-- [[ Remapped keys ]]
vim.keymap.set('n', 's', 'r', { noremap = true })
vim.keymap.set('n', '<C-k>', '<C-u>zz', { noremap = true })
vim.keymap.set('n', '<C-j>', '<C-d>zz', { noremap = true })

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', ':noh', { noremap = true })

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode
vim.keymap.set('t', '<C-q>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', 'gh', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', 'gl', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', 'gk', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
vim.keymap.set('n', 'gj', '<C-w><C-j>', { desc = 'Move focus to the lower window' })

vim.keymap.set('v', '<', '<gv', { desc = 'Decrease indentation and stay in visual mode' })
vim.keymap.set('v', '>', '>gv', { desc = 'Increase indentation and stay in visual mode' })

vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move selected lines down' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move selected lines up' })
