return {
  {
    -- The prototype that combines comments and tours, from the local checkout.
    dir = vim.fn.stdpath 'config' .. '/thread.nvim',
    name = 'thread.nvim',
    event = 'VeryLazy',
    cmd = 'Thread',
    opts = {},
  },
}
