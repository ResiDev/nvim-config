return {
  "tpope/vim-dadbod",
  "kristijanhusak/vim-dadbod-ui",
  "kristijanhusak/vim-dadbod-completion",
  vim.keymap.set('n', '<leader>dy', ':DBUI <CR>', { desc = 'Dadbod UI' })
}
