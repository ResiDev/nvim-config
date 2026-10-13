return {
  {
    -- The prototype that combines comments and tours, from the rebuild's
    -- worktree (the checkout is .../thread.nvim), on its new surfaces.
    dir = vim.fn.stdpath 'config' .. '/thread.nvim/.worktrees/rebuild',
    name = 'thread.nvim',
    event = 'VeryLazy',
    cmd = 'Thread',
    opts = { rebuild = true },
  },
}
