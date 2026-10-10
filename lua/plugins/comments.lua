return {
  {
    -- The local checkout while it is being tried out.
    dir = vim.fn.stdpath 'config' .. '/comments.nvim',
    name = 'comments.nvim',
    event = 'VeryLazy',
    cmd = 'Comments',
    opts = {},
  },
}
