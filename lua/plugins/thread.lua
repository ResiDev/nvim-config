-- The prototype that combines comments and tours, on its new surfaces.
-- From the rebuild's worktree when this machine has it, so edits show
-- without pushing; else cloned from GitHub.
local here = vim.fn.stdpath 'config' .. '/thread.nvim/.worktrees/rebuild'

return {
  {
    'ResiDev/threads',
    name = 'thread.nvim',
    branch = 'master',
    dir = vim.uv.fs_stat(here) and here or nil,
    event = 'VeryLazy',
    cmd = 'Thread',
    opts = { rebuild = true },
  },
}
