-- seam: contracts of a TypeScript repo, from treesitter. :Seam opens it.
-- From the local clone when this machine has it, so edits show without
-- pushing; else cloned from GitHub.
local here = vim.fn.stdpath 'config' .. '/seam.nvim'

return {
  {
    'ResiDev/seam',
    name = 'seam',
    dir = vim.uv.fs_stat(here) and here or nil,
    cmd = { 'Seam', 'SeamLab' },
  },
}
