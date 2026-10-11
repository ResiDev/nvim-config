return {
  {
    -- The prototype that combines comments and tours, from the local checkout.
    dir = vim.fn.stdpath 'config' .. '/thread.nvim',
    name = 'thread.nvim',
    event = 'VeryLazy',
    cmd = 'Thread',
    -- After comments.nvim, so Enter, + and - on a thread are ours and fall
    -- back to its on a comment.
    dependencies = { 'comments.nvim' },
    opts = {},
  },
}
